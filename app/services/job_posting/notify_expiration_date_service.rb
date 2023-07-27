# frozen_string_literal: true

class JobPosting::NotifyExpirationDateService

  def self.call(date)
    self.new(date).call
  end

  def initialize(date)
    @date = date
  end

  def call
    first_notifiable_range = (@date - 6.days)...(@date - 5.days)
    second_notifiable_range = (@date - 11.days)...(@date - 10.days)
    third_notifiable_range = (@date - 16.days)...(@date - 15.days)

    active_job_postings = JobPosting
                            .includes(:business)
                            .active
                            .init
                            .where('closing_at > ?', @date)
                            .where(scraped_worknet_job_posting_id: nil)
                            .where.not(business_id: nil)

    job_postings = active_job_postings
                     .where(published_at: first_notifiable_range)
                     .or(active_job_postings.where(published_at: second_notifiable_range))
                     .or(active_job_postings.where(published_at: third_notifiable_range))

    threads = []
    results = []

    job_postings.find_each do |job_posting|

      threads << Thread.new do
        begin
          business = job_posting.business

          # 사업자 정보 없는 경우
          raise 'business not exists' unless business.present?

          client = business.clients.first

          # 담당자 정보 없는 경우
          raise 'client not exists' unless client.present? and client.phone_number.present?

          host = "https://business.carepartner.kr"
          params = "/recruitment_management/#{job_posting.public_id}/close?a=b"
          link = "#{host}#{params}&utm_source=message&utm_medium=arlimtalk&utm_campaign=close_job_posting_notification"

          message = {
            message_type: 'AI',
            template_id: KakaoTemplate::CLOSE_JOB_POSTING_NOTIFICATION,
            phone: Jets.env.production? ? (ENV['TEST_PHONE_NUMBER'] or '01037863607') : client.phone_number,
            template_params: {
              target_public_id: client.public_id,
              job_posting_public_id: job_posting.public_id,
              title: job_posting.title,
              link: link
            }
          }

          response = KakaoNotificationService.call(
            **message
          )

          results.push({ status: 'success', response: response, message: message })
        rescue => e
          results.push({ status: 'fail', response: response, message: "#{e.message}" })
        end
      end

      # 동시 실행 가능한 최대 스레드 갯수 10개를 초과하면 대기
      if threads.size >= 10
        threads.first.join
        threads.shift
      end
    end

    # 남은 스레드들 처리 종료될 때까지 Wait
    threads.each(&:join)

    {
      results: results
    }
  end
end

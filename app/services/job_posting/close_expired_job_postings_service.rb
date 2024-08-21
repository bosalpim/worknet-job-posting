# frozen_string_literal: true

class JobPosting::CloseExpiredJobPostingsService

  def self.call(date = DateTime.now.beginning_of_day.change(hour: 4, min: 0, sec: 0))
    new(date).call
  end

  def initialize(date = DateTime.now.beginning_of_day.change(hour: 4, min: 0, sec: 0))
    @date = date
  end

  def call
    job_postings = JobPosting
                     .where(status: 'init')
                     .where(scraped_worknet_job_posting_id: nil)
                     .where('closing_at < ?', @date)

    Jets.logger.info "종료대상 공고정보 : #{job_postings.pluck(:public_id)}"

    paid_business_id_list = Business.where.not(paid_feature_transitioned_at: nil).ids
    target_job_posting = job_postings.where(business_id: paid_business_id_list)
    Jets.logger.info "종료대상 중 과금대상 유저의 공고 정보 : #{target_job_posting.pluck(:public_id)}"

    # 종료된 공고 번개채용 전환 유도 알림톡 발송
    if target_job_posting.count > 0
      notification = Notification::FactoryService.create(MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE,  { job_postings: target_job_posting })
      # 발송 (ps. 메세지 성공/실패에 따른 이벤트로깅은 재발송등 사후 처리의 편의성을 위해 Amplitude 로깅이 함께 수행됩니다.)
      notification.notify
      # 발송결과 DB 저장 (사후 처리 대상 구분되도록 DB 내역을 생성해야합니다.)
      notification.save_result
    end

    client_events = job_postings.map do |job_posting|
      {
        user_id: job_posting.client.public_id,
        event_type: "[Action] Close Job Posting",
        event_properties: { by_auto: "true" }
      }
    end

    AmplitudeService.instance.log_array(client_events)

    job_postings.update_all(status: 'closed')
  end
end

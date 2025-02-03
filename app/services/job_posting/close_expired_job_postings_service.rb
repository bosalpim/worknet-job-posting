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

    client_events = job_postings.map do |job_posting|
      {
        user_id: job_posting.client.public_id,
        event_type: "[Action] Close Job Posting By Auto",
        event_properties: { jobPostingId: job_posting.public_id }
      }
    end

    EventLoggingService.instance.log_events(client_events)

    job_postings.update_all(status: 'closed')
  end
end

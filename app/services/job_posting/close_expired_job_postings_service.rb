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
                     .free_job_posting
                     .where('closing_at < ?', @date)

    # 과금대상 기관이 올린 무료공고는 applying_due_date가 'three_days'
    target_job_posting = job_postings.where(applying_due_date: 'three_days')
    # 종료된 공고 번개채용 전환 유도 알림톡 발송
    NotificationServiceJob.perform_later(:notify, { message_template_id: MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE, params: {job_postings: target_job_posting}}) if target_job_posting.count > 0

    job_postings.update_all(status: 'closed')
  end
end

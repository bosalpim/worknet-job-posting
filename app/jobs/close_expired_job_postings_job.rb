# frozen_string_literal: true

class CloseExpiredJobPostingsJob < ApplicationJob
  # (한국 시간) 매일 오전 4시에 closing_at이 지난 공고 마감 처리
  cron "0 19 * * ? *"

  def close_expired_job_postings
    JobPosting::CloseExpiredJobPostingsService.call
  end

  cron "0 19 * * ? *"
  def notify_close_1day_ago_free_job_postings
    NotificationServiceJob.perform_later(:notify, { message_template_id: MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO})
  end
end

# frozen_string_literal: true

class CloseExpiredJobPostingsJob < ApplicationJob
  # (한국 시간) 매일 오전 7시에 closing_at이 지난 공고 마감 처리
  cron "0 22 * * *"

  def close_expired_job_postings
    JobPosting::CloseExpiredJobPostingsSerivce.call
  end
end

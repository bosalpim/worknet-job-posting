class NewJobNotificationJob < ApplicationJob
  def perform(job_posting_id)
    job_posting = JobPosting.find(job_posting_id)
    NewJobNotificationService.call(job_posting)
  end
end

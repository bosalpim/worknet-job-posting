class NewJobNotificationJob < ApplicationJob
  def call
    job_posting = JobPosting.find(event[:job_posting_id])
    NewJobNotificationService.test_call(job_posting) unless Jets.env == 'production'
    NewJobNotificationService.call(job_posting) if Jets.env == 'production'
  end
end

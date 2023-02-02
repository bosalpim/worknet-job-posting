class NewJobNotificationJob < ApplicationJob
  def perform(job_posting_id)
    NewJobNotificationService.call(job_posting_id)
  end
end

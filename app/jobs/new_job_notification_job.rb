class NewJobNotificationJob < ApplicationJob
  def dig
    job_posting = JobPosting.find(event[:job_posting_id])
    Jets.logger.info "ENV: #{Jets.env}, #{Jets.env == 'production'}"
    NewJobNotificationService.test_call(job_posting) unless Jets.env == 'production'
    NewJobNotificationService.call(job_posting) if Jets.env == 'production'
  end
end

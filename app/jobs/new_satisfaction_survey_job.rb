class NewSatisfactionSurveyJob < ApplicationJob
  def dig
    job_posting = JobPosting.find(event[:job_posting_id])
    NewSatisfactionSurveyService.test_call(job_posting) unless Jets.env == 'production'
    NewSatisfactionSurveyService.call(job_posting) if Jets.env == 'production'
  end
end

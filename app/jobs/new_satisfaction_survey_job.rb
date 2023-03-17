class NewSatisfactionSurveyJob < ApplicationJob
  def dig
    job_posting = JobPosting.find(event[:job_posting_id])
    NewSatisfactionSurveyService.call(job_posting)
  end
end

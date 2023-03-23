class NewUserSatisfactionSurveyJob < ApplicationJob
  def dig
    job_posting = JobPosting.find(event[:job_posting_id])
    user = User.find(event[:user_id])
    NewUserSatisfactionSurveyService.call(job_posting, user)
  end
end

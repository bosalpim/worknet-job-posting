class UserCallFailureAlertJob < ApplicationJob
  def dig
    user = User.find(event[:user_id])
    job_posting = JobPosting.find(event[:job_posting_id])
    UserCallFailureAlertService.call(user, job_posting)
  end
end

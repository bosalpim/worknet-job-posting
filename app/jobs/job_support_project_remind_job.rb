class JobSupportProjectRemindJob < ApplicationJob

  cron "0 0 ? * * *"
  def first_submit_remind
    JobSupportProject::FirstSubmitRemindService.call
  end

  cron "0 4 ? * * *"
  def second_submit_remind
  end

end
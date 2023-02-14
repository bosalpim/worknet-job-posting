class PersonalNotificationJob < ApplicationJob
  cron "35 11 ? * TUE *" # “At 12:00 on Thursday in Korean Time”
  def personal
    PersonalNotificationService.call
  end
end

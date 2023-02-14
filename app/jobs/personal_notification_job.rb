class PersonalNotificationJob < ApplicationJob
  cron "52 8 ? * TUE *" # “At 12:00 on Thursday in Korean Time”
  def personal
    PersonalNotificationService.call
  end
end

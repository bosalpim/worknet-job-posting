class PersonalNotificationJob < ApplicationJob
  cron "15 7 ? * TUE *" # “At 12:00 on Monday in Korean Time”
  def personal
    PersonalNotificationService.call
  end
end

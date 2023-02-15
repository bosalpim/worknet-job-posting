class PersonalNotificationJob < ApplicationJob
  cron "0 3 ? * Mon *" # “At 12:00 on Monday in Korean Time”
  def personal
    PersonalNotificationService.call
  end
end

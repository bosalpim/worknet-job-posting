class PersonalNotificationJob < ApplicationJob
  cron "0 3 ? * MON *" # “At 12:00 on Monday in Korean Time”
  def personal
    PersonalNotificationService.call
  end
end

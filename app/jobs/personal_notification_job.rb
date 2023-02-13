class PersonalNotificationJob < ApplicationJob
  cron "0 4 ? * MON *" # “At 12:00 on Monday in Korean Time”
  def personal
    PersonalNotificationService.call if Jets.env == 'production'
    PersonalNotificationService.test_call unless Jets.env == 'production'
  end
end

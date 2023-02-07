class PersonalNotificationJob < ApplicationJob
  cron "0 3 * * 1" # “At 12:00 on Monday in Korean Time”
  def dig
    PersonalNotificationService.new.call if Jets.env == 'production'
    PersonalNotificationService.new.test_call unless Jets.env == 'production'
  end
end

class PersonalNotificationJob < ApplicationJob
  cron "0 3 ? * MON *" # “At 12:00 on Monday in Korean Time”
  def send_1_percent
    PersonalNotificationService.call(0.01, 0)
  end

  cron "10 3 ? * MON *" # “At 12:10 on Monday in Korean Time”
  def send_9_percent
    PersonalNotificationService.call(0.09, 0.01)
  end

  cron "20 3 ? * MON *" # “At 12:20 on Monday in Korean Time”
  def send_20_percent
    PersonalNotificationService.call(0.20, 0.10)
  end

  cron "25 3 ? * MON *" # “At 12:25 on Monday in Korean Time”
  def send_35_percent
    PersonalNotificationService.call(0.35, 0.30)
  end

  cron "30 3 ? * MON *" # “At 12:30 on Monday in Korean Time”
  def send_last_35_percent
    PersonalNotificationService.call(0.35, 0.65)
  end
end

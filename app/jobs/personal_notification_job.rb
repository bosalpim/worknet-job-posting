class PersonalNotificationJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "0 3 ? * MON *"
  def send_step_0
    PersonalNotificationService.call(0.1, 0)
  end

  cron "5 3 ? * MON *"
  def send_step_1
    PersonalNotificationService.call(0.1, 0.1)
  end

  cron "10 3 ? * MON *"
  def send_step_2
    PersonalNotificationService.call(0.1, 0.2)
  end

  cron "15 3 ? * MON *"
  def send_step_3
    PersonalNotificationService.call(0.1, 0.3)
  end

  cron "20 3 ? * MON *"
  def send_step_4
    PersonalNotificationService.call(0.1, 0.4)
  end

  cron "15 5 ? * MON *"
  def send_step_5
    PersonalNotificationService.call(0.1, 0.5)
  end

  cron "25 5 ? * MON *"
  def send_step_6
    PersonalNotificationService.call(0.1, 0.6)
  end

  cron "35 5 ? * MON *"
  def send_step_7
    PersonalNotificationService.call(0.1, 0.7)
  end

  cron "45 5 ? * MON *"
  def send_step_8
    PersonalNotificationService.call(0.1, 0.8)
  end

  cron "55 5 ? * MON *"
  def send_step_9
    PersonalNotificationService.call(0.1, 0.9)
  end
end

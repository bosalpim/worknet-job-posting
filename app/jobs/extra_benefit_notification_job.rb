class ExtraBenefitNotificationJob < ApplicationJob
  # "From 12:00 on Thursday in Korean Time"
  cron "2 3 ? * THU *"
  def send_step_0
    ExtraBenefitNotificationService.call(0.1, 0)
  end

  cron "12 3 ? * THU *"
  def send_step_1
    ExtraBenefitNotificationService.call(0.1, 0.1)
  end

  cron "22 3 ? * THU *"
  def send_step_2
    ExtraBenefitNotificationService.call(0.1, 0.2)
  end

  cron "32 3 ? * THU *"
  def send_step_3
    ExtraBenefitNotificationService.call(0.1, 0.3)
  end

  cron "42 3 ? * THU *"
  def send_step_4
    ExtraBenefitNotificationService.call(0.1, 0.4)
  end

  cron "52 3 ? * THU *"
  def send_step_5
    ExtraBenefitNotificationService.call(0.1, 0.5)
  end

  cron "2 4 ? * THU *"
  def send_step_6
    ExtraBenefitNotificationService.call(0.1, 0.6)
  end

  cron "12 4 ? * THU *"
  def send_step_7
    ExtraBenefitNotificationService.call(0.1, 0.7)
  end

  cron "22 4 ? * THU *"
  def send_step_8
    ExtraBenefitNotificationService.call(0.1, 0.8)
  end

  cron "32 4 ? * THU *"
  def send_step_9
    ExtraBenefitNotificationService.call(0.1, 0.9)
  end
end

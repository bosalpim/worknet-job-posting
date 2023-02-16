class ExtraBenefitNotificationJob < ApplicationJob
  cron "0 3 ? * THU *" # “At 12:00 on Thursday in Korean Time”
  def send_1_percent
    ExtraBenefitNotificationService.call(0.01, 0)
  end

  cron "10 3 ? * THU *" # “At 12:10 on Thursday in Korean Time”
  def send_9_percent
    ExtraBenefitNotificationService.call(0.09, 0.01)
  end

  cron "20 4 ? * THU *" # “At 12:20 on Thursday in Korean Time”
  def send_20_percent
    ExtraBenefitNotificationService.call(0.20, 0.10)
  end

  cron "2 5 ? * THU *" # “At 12:25 on Thursday in Korean Time”
  def send_35_percent
    ExtraBenefitNotificationService.call(0.35, 0.30)
  end

  cron "30 4 ? * THU *" # “At 12:30 on Thursday in Korean Time”
  def send_last_35_percent
    ExtraBenefitNotificationService.call(0.35, 0.65)
  end
end

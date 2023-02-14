class ExtraBenefitNotificationJob < ApplicationJob
  cron "0 3 ? * THU *" # “At 12:00 on Thursday in Korean Time”
  def extra
    ExtraBenefitNotificationService.call
  end
end

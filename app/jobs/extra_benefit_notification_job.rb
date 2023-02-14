class ExtraBenefitNotificationJob < ApplicationJob
  cron "46 10 ? * TUE *" # “At 12:00 on Thursday in Korean Time”
  def extra
    ExtraBenefitNotificationService.call
  end
end

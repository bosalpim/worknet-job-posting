class ExtraBenefitNotificationJob < ApplicationJob
  cron "1 8 ? * TUE *" # “At 12:00 on Thursday in Korean Time”
  def extra
    ExtraBenefitNotificationService.call
  end
end

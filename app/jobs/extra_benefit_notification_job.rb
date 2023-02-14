class ExtraBenefitNotificationJob < ApplicationJob
  cron "0 5 ? * TUE *" # “At 12:00 on Thursday in Korean Time”
  def extra
    ExtraBenefitNotificationService.call
  end
end

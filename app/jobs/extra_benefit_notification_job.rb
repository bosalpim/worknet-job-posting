class ExtraBenefitNotificationJob < ApplicationJob
  cron "0 3 * * 4" # “At 12:00 on Thursday in Korean Time”
  def dig
    ExtraBenefitNotificationService.new.call if Jets.env == 'production'
    ExtraBenefitNotificationService.new.test_call unless Jets.env == 'production'
  end
end

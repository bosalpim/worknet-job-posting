class ExtraBenefitNotificationJob < ApplicationJob
  # cron "0 3 * * 4 *" # “At 12:00 on Thursday in Korean Time”
  def extra
    ExtraBenefitNotificationService.call if Jets.env == 'production'
    ExtraBenefitNotificationService.test_call unless Jets.env == 'production'
  end
end

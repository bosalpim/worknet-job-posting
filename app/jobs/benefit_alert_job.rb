class BenefitAlertJob < ApplicationJob
  include NotificationType

  cron "0 9 * * ? *"
  def notify_coupang_partners(date = nil)
    factory = Notification::Factory::CoupangPartnersBenefit.new
    factory.notify
    factory.save_result
  end
end

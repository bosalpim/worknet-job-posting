class CreateScheduledMessageJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "0 17 ? * SUN *"
  def create_extra_benefit_notification_message
    CreatePersonalNotificationMessageService.call
  end

  cron "0 17 ? * WED *"
  def create_personal_notification_message
    CreateExtraBenefitNotificationMessageService.call
  end
end

class CreateScheduledMessageJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "0 20 ? * SUN *"
  def create_personal_notification_message
    CreateNewsPaperActivelyCommonMessageService.call
  end

  # cron "0 20 ? * WED *" # HM : 원복
  cron "40 2 ? * WED *"
  def create_extra_benefit_notification_message
    CreateNewsPaperActivelyCommonMessageService.call
  end
end

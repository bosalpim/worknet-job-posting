class CreateScheduledMessageJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "0 20 ? * SUN *"
  def create_personal_notification_message
    CreateNewsPaperActivelyCommonMessageService.call
  end

  # cron "0 20 ? * WED *" # HM : 원복
  # 18 - 9 = 9
  cron "20 9 ? * TUE *"
  def create_extra_benefit_notification_message
    CreateNewsPaperActivelyCommonMessageService.call
  end
end

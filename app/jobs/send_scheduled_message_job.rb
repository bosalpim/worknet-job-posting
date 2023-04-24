class SendScheduledMessageJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "2 3 ? * THU *"
  def send_extra_benefit_notification_message_0
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0)
  end

  cron "12 3 ? * THU *"
  def send_extra_benefit_notification_message_1
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.1)
  end

  cron "22 3 ? * THU *"
  def send_extra_benefit_notification_message_2
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.2)
  end

  cron "32 3 ? * THU *"
  def send_extra_benefit_notification_message_3
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.3)
  end

  cron "42 3 ? * THU *"
  def send_extra_benefit_notification_message_4
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.4)
  end

  cron "52 3 ? * THU *"
  def send_extra_benefit_notification_message_5
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.5)
  end

  cron "2 4 ? * THU *"
  def send_extra_benefit_notification_message_6
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.6)
  end

  cron "12 4 ? * THU *"
  def send_extra_benefit_notification_message_7
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.7)
  end

  cron "22 4 ? * THU *"
  def send_extra_benefit_notification_message_8
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.8)
  end

  cron "32 4 ? * THU *"
  def send_extra_benefit_notification_message_9
    SendCreatedScheduledMessageService.call(KakaoTemplate::EXTRA_BENEFIT, KakaoNotificationResult::EXTRA_BENEFIT, 0.1, 0.9)
  end

  # --------------------------------------------------------------------

  cron "2 3 ? * MON *"
  def send_personal_notification_message_0
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0)
  end

  cron "12 3 ? * MON *"
  def send_personal_notification_message_1
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.1)
  end

  cron "22 3 ? * MON *"
  def send_personal_notification_message_2
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.2)
  end

  cron "32 3 ? * MON *"
  def send_personal_notification_message_3
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.3)
  end

  cron "42 3 ? * MON *"
  def send_personal_notification_message_4
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.4)
  end

  cron "52 3 ? * MON *"
  def send_personal_notification_message_5
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.5)
  end

  cron "2 4 ? * MON *"
  def send_personal_notification_message_6
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.6)
  end

  cron "12 4 ? * MON *"
  def send_personal_notification_message_7
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.7)
  end

  cron "22 4 ? * MON *"
  def send_personal_notification_message_8
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.8)
  end

  cron "32 4 ? * MON *"
  def send_personal_notification_message_9
    SendCreatedScheduledMessageService.call(KakaoTemplate::PERSONALIZED, KakaoNotificationResult::PERSONALIZED, 0.1, 0.9)
  end
end

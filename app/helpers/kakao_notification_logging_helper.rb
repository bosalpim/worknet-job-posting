module KakaoNotificationLoggingHelper
  NOTIFICATION_EVENT_NAME = '[Action] Receive Notification'

  SENDER_TYPE_CAREPARTNER = 'carepartner'
  SENDER_TYPE_BUSINESS = 'business'
  SENDER_TYPE_USER = 'user'

  RECEIVER_TYPE_BUSINESS = 'business'
  RECEIVER_TYPE_USER = 'user'

  NOTIFICATION_TYPE_KAKAO = 'kakao_notification'
  NOTIFICATION_TYPE_RESERVED = 'kakao_notification_reserved'
  NOTIFICATION_TYPE_APP_PUSH = 'app_push'
  NOTIFICATION_TYPE_TEXT_MESSAGE = 'text_message'
  def self.get_logging_data(template_id, tem_params, phone)
    case template_id
    when KakaoTemplate::PROPOSAL
      return nil
    when KakaoTemplate::NEW_JOB_POSTING_VISIT
      return nil
    when KakaoTemplate::NEW_JOB_POSTING_FACILITY
      return nil
    when KakaoTemplate::PERSONALIZED
      return nil
    when KakaoTemplate::EXTRA_BENEFIT
      return nil
    when KakaoTemplate::PROPOSAL_ACCEPTED
      return nil
    when KakaoTemplate::PROPOSAL_REJECTED
      return nil
    when KakaoTemplate::SATISFACTION_SURVEY
      return nil
    when KakaoTemplate::USER_SATISFACTION_SURVEY
      return nil
    when KakaoTemplate::USER_CALL_REMINDER
      return nil
    when KakaoTemplate::BUSINESS_CALL_REMINDER
      return nil
    when KakaoTemplate::CALL_REQUEST_ALARM
      return nil
    when KakaoTemplate::BUSINESS_CALL_APPLY_USER_REMINDER
      return nil
    when KakaoTemplate::JOB_ALARM_ACTIVELY
      return get_news_paper_logging_data(template_id, phone)
    when KakaoTemplate::JOB_ALARM_COMMON
      return nil
    when KakaoTemplate::JOB_ALARM_OFF
      return get_news_paper_logging_data(template_id, phone)
    when KakaoTemplate::JOB_ALARM_WORKING
      return get_news_paper_logging_data(template_id, phone)
    when KakaoTemplate::GAMIFICATION_MISSION_COMPLETE
      return nil
    else
      puts "WARNING: Amplitude Logging Missing else case!"
    end
  end
  def self.get_news_paper_logging_data(template_id, phone)
    target_public_id = User.find_by(phone_number: phone).public_id
    return {
      "target_public_id" => target_public_id,
      "event_name" => NOTIFICATION_EVENT_NAME,
      "properties" => {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_USER,
        "template" => template_id,
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end
end
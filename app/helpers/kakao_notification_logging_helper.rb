module KakaoNotificationLoggingHelper
  NOTIFICATION_EVENT_NAME = '[Action] Receive Notification'
  NOTIFICATION_EVENT_NAME2 = '[Action] Receive Notification2'

  SENDER_TYPE_CAREPARTNER = 'carepartner'
  SENDER_TYPE_BUSINESS = 'business'
  SENDER_TYPE_USER = 'user'

  RECEIVER_TYPE_BUSINESS = 'business'
  RECEIVER_TYPE_USER = 'user'

  NOTIFICATION_TYPE_KAKAO = 'kakao_notification'
  NOTIFICATION_TYPE_RESERVED = 'kakao_notification_reserved'
  NOTIFICATION_TYPE_APP_PUSH = 'app_push'
  NOTIFICATION_TYPE_TEXT_MESSAGE = 'text_message'

  def self.get_logging_data2(template_id, tem_params)
    target_public_id = tem_params.dig(:target_public_id)
    target_public_id = tem_params.dig("target_public_id") if target_public_id.nil?

    if target_public_id.nil?
      return nil
    end

    return {
      "target_public_id" => target_public_id,
      "event_name" => NOTIFICATION_EVENT_NAME2,
      "properties" => {
        "template" => template_id,
        "template_params" => tem_params
      }
    }
  end

  def self.get_logging_data(template_id, tem_params)
    target_public_id = tem_params.dig(:target_public_id)
    target_public_id = tem_params.dig("target_public_id") if target_public_id.nil?

    if target_public_id.nil?
      return nil
    end

    case template_id
      when KakaoTemplate::NEW_JOB_POSTING_VISIT
        return self.get_new_job_posting_logging_data(tem_params, template_id, target_public_id)
      when KakaoTemplate::NEW_JOB_POSTING_FACILITY
        return self.get_new_job_posting_logging_data(tem_params, template_id, target_public_id)
      when KakaoTemplate::JOB_ALARM_ACTIVELY
        return get_news_paper_logging_data(template_id, target_public_id)
      when KakaoTemplate::JOB_ALARM_OFF
        return get_news_paper_logging_data(template_id, target_public_id)
      when KakaoTemplate::JOB_ALARM_WORKING
        return get_news_paper_logging_data(template_id, target_public_id)
    else
      puts "WARNING: Amplitude Logging Missing else case!"
    end
  end
  def self.get_new_job_posting_logging_data(template_params, template_id, target_public_id)
    job_posting_public_id = template_params.dig(:job_posting_public_id)
    job_posting_title = template_params.dig(:job_posting_title)
    business_name = template_params.dig(:business_name)

    return {
      "target_public_id" => target_public_id,
      "event_name" => NOTIFICATION_EVENT_NAME,
      "properties" => {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_USER,
        "template" => template_id,
        "job_posting_public_id" => job_posting_public_id,
        "job_posting_title" => job_posting_title,
        "business_name" => business_name,
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_news_paper_logging_data(template_id, target_public_id)
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
  def self.send_log(response, template_id, template_params)
    logging_data = get_logging_data(template_id, template_params)
    logging_data2 = get_logging_data2(template_id, template_params)

    return if logging_data.nil?
    return if logging_data2.nil?

    response_code = response.dig("code")
    response_message = response.dig("message")
    if response_code == "success"
      if response_message == "K000"
        logging_data["properties"]["type"] = NOTIFICATION_TYPE_KAKAO
        logging_data2["properties"]["type"] = NOTIFICATION_TYPE_KAKAO
      elsif response_message == "R000"
        logging_data["properties"]["type"] = NOTIFICATION_TYPE_RESERVED
        logging_data2["properties"]["type"] = NOTIFICATION_TYPE_RESERVED
      else
        logging_data["properties"]["type"] = NOTIFICATION_TYPE_TEXT_MESSAGE
        logging_data2["properties"]["type"] = NOTIFICATION_TYPE_TEXT_MESSAGE
      end

      AmplitudeService.instance.log(logging_data["event_name"], logging_data["properties"], logging_data["target_public_id"])
      AmplitudeService.instance.log(logging_data2["event_name"], logging_data2["properties"], logging_data2["target_public_id"])
    else
      return
    end
  end
end
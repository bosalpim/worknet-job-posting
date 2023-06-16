module KakaoNotificationLoggingHelper
  NOTIFICATION_EVENT_NAME = '[Action] Receive Notification'
  NOTIFICATION_TYPE_KAKAO = 'kakao_notification'
  NOTIFICATION_TYPE_RESERVED = 'kakao_notification_reserved'
  NOTIFICATION_TYPE_APP_PUSH = 'app_push'
  NOTIFICATION_TYPE_TEXT_MESSAGE = 'text_message'

  def self.get_logging_data(template_id, tem_params)
    target_public_id = tem_params.dig(:target_public_id)
    target_public_id = tem_params.dig("target_public_id") if target_public_id.nil?

    return {
      "target_public_id" => target_public_id,
      "event_name" => NOTIFICATION_EVENT_NAME,
      "properties" => {
        "template" => template_id,
        "template_params" => tem_params
      }
    }
  end
  def self.send_log(response, template_id, template_params)
    logging_data = get_logging_data(template_id, template_params)
    return if logging_data.nil?

    response_code = response.dig("code")
    response_message = response.dig("message")
    if response_code == "success"
      if response_message == "K000"
        logging_data["properties"]["type"] = NOTIFICATION_TYPE_KAKAO
      elsif response_message == "R000"
        logging_data["properties"]["type"] = NOTIFICATION_TYPE_RESERVED
      else
        logging_data["properties"]["type"] = NOTIFICATION_TYPE_TEXT_MESSAGE
      end
      AmplitudeService.instance.log(logging_data["event_name"], logging_data["properties"], logging_data["target_public_id"])
    else
      return
    end
  end
end
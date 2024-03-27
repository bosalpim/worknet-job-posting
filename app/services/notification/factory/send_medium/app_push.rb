class Notification::Factory::SendMedium::AppPush < Notification::Factory::SendMedium::Abstract
  include NotificationRequestHelper
  # FCM
  def initialize(message_template_id, to, collapse_key, notification, target_public_id, logging_properties = nil)
    @message_template_id = message_template_id
    @to = to
    @collapse_key = collapse_key
    @notification = notification
    @target_public_id = target_public_id
    @logging_properties = logging_properties
  end

  # FCM
  def send_request
    begin
      response = request_app_push({ to: @to, collapse_key: @collapse_key, notification: @notification })
      success = response["success"]
      if success == 1
        amplitude_log unless @logging_properties.nil?
        return { status: 'success', response: response, target_public_id: @target_public_id }
      else
        begin
          if response["results"].first["error"] == 'NotRegistered'
            UserPushToken.find_by(token: @to).destroy rescue nil
            ClientPushToken.find_by(token: @to).destroy rescue nil
          end
        rescue => e
          Jets.logger.error e.full_message
        end

        return { status: 'fail', response: response.to_s, target_public_id: @target_public_id }
      end
    rescue Net::ReadTimeout
      return { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      return { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end

  def amplitude_log
    AmplitudeService.instance.log_array([{
                                           "user_id" => @target_public_id,
                                           "event_type" => KakaoNotificationLoggingHelper::NOTIFICATION_EVENT_NAME,
                                           "event_properties" => @logging_properties
                                         }])
  end
end
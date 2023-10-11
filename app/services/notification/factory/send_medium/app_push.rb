class Notification::Factory::SendMedium::AppPush
  include NotificationRequestHelper
  # FCM
  def initialize(message_template_id, to, collapse_key, notification, target_public_id)
    @message_template_id = message_template_id
    @to = to
    @collapse_key = collapse_key
    @notification = notification
    @target_public_id = target_public_id
  end

  # FCM
  def send_request
    begin
      response = request_app_push({ to: @to, collapse_key: @collapse_key, notification: @notification })
      success = response["success"]
      if success == 1
        return { status: 'success', response: response, target_public_id: @target_public_id }
      else
        return { status: 'fail', response: response.to_s, target_public_id: @target_public_id }
      end
    rescue Net::ReadTimeout
      return { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      return { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end
end
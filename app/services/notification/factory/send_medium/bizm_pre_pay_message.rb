class Notification::Factory::SendMedium::BizmPrePayMessage
  include NotificationRequestHelper
  def initialize(message_template_id, phone, params, target_public_id)
    @message_template_id = message_template_id
    @params = params
    @target_public_id = target_public_id
    @bizm_template_service = KakaoTemplateService.new(message_template_id, message_type, phone, nil)
  end

  def send_request
    request_params = @bizm_template_service.get_final_request_params(@params, true)
    begin
      response = request_pre_pay(request_params)
      response.class == Array ? response.first : response
      amplitude_log(response)
      { status: 'success', response: response, target_public_id: @target_public_id }
    rescue Net::ReadTimeout
      { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end

  def amplitude_log(response)
    KakaoNotificationLoggingHelper.send_log(response, @message_template_id, @params)
  end
end
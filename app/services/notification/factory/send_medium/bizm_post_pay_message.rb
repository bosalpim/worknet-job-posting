class Notification::Factory::SendMedium::BizmPostPayMessage < Notification::Factory::SendMedium::Abstract
  include NotificationRequestHelper
  def initialize(message_template_id, phone, params, target_public_id, message_type = "AT", reserved_dt = nil, alt_sms_btn_indexes = [])
    @message_template_id = message_template_id
    params[:target_public_id] = target_public_id
    @params = params
    @target_public_id = target_public_id
    @bizm_template_service = KakaoTemplateService.new(message_template_id, message_type, phone, reserved_dt, alt_sms_btn_indexes)
  end

  def send_request
    request_params = @bizm_template_service.get_final_request_params(@params, false)
    { status: 'fail', response: "테스터 번호가 아닙니다.", target_public_id: @target_public_id } if request_params.nil? && !(Jets.env.production?)
    begin
      response = request_post_pay(request_params)
      response.class == Array ? response.first : response
      event_log(response)
      { status: 'success', response: response, target_public_id: @target_public_id }
    rescue Net::ReadTimeout
      { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end

  def event_log(response)
    KakaoNotificationLoggingHelper.send_log_for_bizmsg(response, @message_template_id, @params)
  end
end
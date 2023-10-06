class KakaoNotificationService
  include NotificationRequestHelper

  def self.call(template_id:, phone:, message_type: "AT", reserve_dt: nil, template_params:)
    new(
      template_id: template_id,
      phone: phone,
      message_type: message_type,
      reserve_dt: reserve_dt,
      template_params: template_params
    ).call
  end

  def initialize(template_id:, phone:, message_type:, reserve_dt:, template_params:)
    @template_service = KakaoTemplateService.new(template_id, message_type, phone, reserve_dt)
    @template_params = template_params
    @template_id = template_id
  end

  def call
    request_params = @template_service.get_final_request_params(@template_params, true)
    begin
      response = request_pre_pay(request_params)
      log_result(response)
      return response
    rescue => e
      puts e.message
      return {
        "code" => "fail",
        "originMessage" => e.message,
        "message" => "error"
      }
    end
  end

  private

  def log_result(response)
    KakaoNotificationLoggingHelper.send_log(response, @template_id, @template_params) rescue nil
    Jets.logger.info "KAKAOMESSAGE #{response.to_yaml}" if Jets.env != 'production'
  end
end
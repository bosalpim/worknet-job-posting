class BizmsgService
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

  def initialize(template_id:, phone:, message_type:, reserve_dt:, template_params:, alt_sms_btn_indexes: [])
    @template_service = KakaoTemplateService.new(template_id, message_type, phone, reserve_dt, alt_sms_btn_indexes)
    @template_params = template_params
    @template_id = template_id
  end

  def call
    request_params = @template_service.get_final_request_params(@template_params)

    begin
      response = request_post_pay(request_params)
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
    KakaoNotificationLoggingHelper.send_log_for_bizmsg(response, @template_id, @template_params) rescue nil
    Jets.logger.info "KAKAOMESSAGE #{response.to_yaml}" if Jets.env != 'production'
  end
end
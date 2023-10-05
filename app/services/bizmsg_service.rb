class BizmsgService
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
    @base_url = "https://alimtalk-api.sweettracker.net/v2/#{ENV['KAKAO_BIZMSG_PROFILE']}/sendMessage"
    @user_id = "bosalpim21"
    @template_id = template_id
  end

  def call
    request_params = @template_service.get_final_request_params(@template_params)

    begin
      return send_request(request_params)
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

  def send_request(request_params)
    response = HTTParty.post(
      @base_url,
      body: JSON.dump([request_params]),
      headers: headers,
      timeout: 10
    ).parsed_response

    response = response.class == Array ? response.first : response
    KakaoNotificationLoggingHelper.send_log_for_bizmsg(response, @template_id, @template_params) rescue nil
    Jets.logger.info "KAKAOMESSAGE #{response.to_yaml}" if Jets.env != 'production'
    response
  end

  def current_time
    "#{Time.now.strftime("%y%m%d%H%M%S")}_#{SecureRandom.uuid.gsub('-', '')[0, 7]}"
  end

  def headers
    {
      "userid" => @user_id,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end
end
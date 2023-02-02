class KakaoNotificationService < KakaoTemplateService
  attr_reader :template_id, :base_url, :user_id, :profile, :sender_number, :phone, :message_type, :reserve_dt

  def self.call(template_id:, phone:, message_type: "AT", reserve_dt: "00000000000000" ,template_params:)
    new(
      template_id: template_id,
      phone: phone,
      message_type: message_type,
      reserve_dt: reserve_dt
    ).call(**template_params)
  end

  def initialize(template_id:, phone:, message_type:, reserve_dt:)
    super(template_id)
    @base_url = "https://alimtalk-api.bizmsg.kr/v2/sender/send"
    @user_id = "bosalpim21"
    @profile = ENV['KAKAO_BIZMSG_PROFILE']
    @sender_number = "15885877"
    @phone = phone
    @message_type = message_type
    @reserve_dt = reserve_dt
  end

  def call(**template_params)
    request_params = get_final_request_params(template_params)
    begin
      send_request(request_params)
    rescue => e
      # Sentry.capture_exception(e)
      puts e.message
    end
  end

  private

  def send_request(request_params)
    response = HTTParty.post(
      base_url,
      body: JSON.dump([request_params]),
      headers: headers
    )
    Jets.logger.info "KAKAOMESSAGE #{response.to_yaml}"
    response
  end

  def get_final_request_params(tem_params)
    template_data = get_template_data(template_id, tem_params)
    request_params = get_default_request_params(template_data)
    if (items = template_data[:items])
      request_params[:items] = items
    end
    if (buttons = template_data[:buttons])
      buttons.each_with_index do |btn, index|
        request_params["button#{index + 1}"] = btn
      end
    end
    if (quick_replies = template_data[:quick_replies])
      quick_replies.each_with_index do |quick_reply, index|
        request_params["quickReply#{index + 1}"] = quick_reply
      end
    end
    request_params
  end

  def get_default_request_params(template_data)
    message, img_url, title = template_data.values_at(:message, :img_url, :title)
    {
      message_type: message_type,
      phn:          phone.to_s.gsub(/[^0-9]/, ""),
      profile:      profile,
      tmplId:       template_id,
      msg:          message,
      smsKind:      message&.bytesize&.to_i > 90 ? "L" : "S",
      msgSms:       message,
      smsSender:    sender_number,
      smsLmsTit:    title,
      img_url:      img_url,
      reserveDt:    reserve_dt
    }
  end

  def headers
    {
      "userid" => user_id,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end
end
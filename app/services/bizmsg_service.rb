class BizmsgService < KakaoTemplateService
  DEFAULT_RESERVE_AT = "00000000000000".freeze # send right now

  attr_reader :template_id, :base_url, :user_id, :profile, :sender_number, :phone, :message_type, :reserve_dt, :template_params

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
    super(template_id)
    profile = ENV['KAKAO_BIZMSG_PROFILE']
    @base_url = "https://alimtalk-api.sweettracker.net/v2/#{profile}/sendMessage"
    @user_id = "bosalpim21"
    @profile = profile
    @sender_number = "15885877"
    @phone = phone
    @message_type = message_type
    @reserve_dt = get_reserve_dt(reserve_dt)
    @template_params = template_params
  end

  def call
    request_params = get_final_request_params(template_params)

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
      base_url,
      body: JSON.dump([request_params]),
      headers: headers,
      timeout: 10
    ).parsed_response

    response = response.class == Array ? response.first : response
    KakaoNotificationLoggingHelper.send_log_for_bizmsg(response, template_id, template_params) rescue nil
    Jets.logger.info "KAKAOMESSAGE #{response.to_yaml}" if Jets.env != 'production'
    response
  end

  def get_final_request_params(tem_params)
    template_data = get_template_data(template_id, tem_params)
    request_params = get_default_request_params(template_id, template_data)
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

  def current_time
    "#{Time.now.strftime("%y%m%d%H%M%S")}_#{SecureRandom.uuid.gsub('-', '')[0, 7]}"
  end

  def get_default_request_params(template_id, template_data)
    message, img_url, title = template_data.values_at(:message, :img_url, :title)
    data = {
      msgid: "WEB#{current_time}",
      message_type: message_type,
      profile_key: profile,
      template_code: template_id,
      receiver_num: phone.to_s.gsub(/[^0-9]/, ""),
      message: message,
      reserved_time: reserve_dt,
      sms_message: message,
      sms_title: title,
      sms_kind: message&.bytesize&.to_i > 90 ? "L" : "S",
      sender_num: sender_number,
      image_url: img_url,
    }
    if template_id == KakaoTemplate::NEW_JOB_POSTING_VISIT || template_id == KakaoTemplate::NEW_JOB_POSTING_FACILITY || template_id == KakaoTemplate::CONTRACT_AGENCY_ALARM || template_id == KakaoTemplate::CONTRACT_AGENCY_ALARM_EDIT2
      data[:title] = title
    end
    return data
  end

  def headers
    {
      "userid" => user_id,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def get_reserve_dt(reserve_dt)
    return reserve_dt if reserve_dt
    american_time = Time.current
    korean_offset = 9 * 60 * 60 # 9 hours ahead of American time
    korean_time = american_time + korean_offset

    if korean_time.hour >= 21
      next_day_time = korean_time + 1.day
      next_day_time.strftime("%Y%m%d") + "080000"
    elsif korean_time.hour < 8
      korean_time.strftime("%Y%m%d") + "080000"
    else
      DEFAULT_RESERVE_AT
    end
  end
end
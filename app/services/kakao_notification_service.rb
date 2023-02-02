class KakaoNotificationService


  attr_reader :template_id, :phone, :base_url

  # kakao_notification_service = KakaoNotificationService.new(template_id: "proposal_02", phone: "01097912095")
  # kakao_notification_service.call(
  #   title: "",
  #   ...
  # )

  def initialize(template_id:, phone:)
    @base_url = "https://alimtalk-api.bizmsg.kr/v2/sender/send"
    @template_id = template_id
    @phone = phone
  end

  def call(message_type:, title:, tem_params: {}, items: [], buttons: [], quick_replies: [], img_url: "https://mud-kage.kakao.com/dn/btfYkj/btrXIoI2ckc/85jhQdX5TuqNEdfrfBXgX0/img_l.jpg")
    message = template_message(template_id, tem_params)

    request_params = {
      message_type: message_type,
      phn: phone.to_s.gsub(/[^0-9]/, ""),
      profile: ENV['KAKAO_BIZMSG_PROFILE'],
      tmplId: template_id,
      msg: message,
      smsKind: message&.bytesize&.to_i > 90 ? "L" : "S",
      msgSms: message,
      smsSender: "15885877",
      smsLmsTit: title,
      img_url: img_url,
    }
    if items
      request_params[:items] = items
    end
    if buttons
      buttons.each_with_index do |btn, index|
        request_params["button#{index + 1}"] = btn
      end
    end
    if quick_replies
      quick_replies.each_with_index do |quick_reply, index|
        request_params["quickReply#{index + 1}"] = quick_reply
      end
    end
    messages = [request_params]
    begin
      response = HTTParty.post(
        base_url,
        body: JSON.dump(messages),
        headers: {
          "userid" => "bosalpim21",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      )
      logger.info "KAKAOMESSAGE #{response.to_yaml}"
      response
    rescue => e
      # Sentry.capture_exception(e)
      puts e.message
    end
  end

  private

  def template_message(template_id, tem_params)
    case template_id
    when "biz_facilitycare_suggestion_1"
      facility_proposal_1(tem_params[:user_name], tem_params[:business_name], tem_params[:business_vn])
    when "biz_facilitycare_suggestion"
      facility_proposal(tem_params[:user_name], tem_params[:business_name], tem_params[:business_vn])
    when "biz_homecare_suggestion_1"
      biz_homecare_suggestion_1(tem_params[:user_name], tem_params[:business_name], tem_params[:business_vn])
    when "biz_homecare_suggestion"
      biz_homecare_suggestion(tem_params[:user_name], tem_params[:business_name], tem_params[:business_vn])
    else
      # Sentry.capture_message("존재하지 않는 메시지 템플릿 요청입니다: template_id: #{template_id}, tem_params: #{tem_params.to_json}")
    end
  end

  def biz_homecare_suggestion_1(user_name, business_name, business_vn)
    "안녕하세요 #{user_name || '요양보호사'} 선생님\n#{business_name} 에서 요양보호사 일자리를 제안하셨어요!\n\n근무 가능하신 선생님은 아래 안심 번호로 연락부탁드려요!\n#{good_number(business_vn)}\n\n[ 빠르게 연락할 수록 근무 가능성이 높아져요 ]"
  end

  def biz_homecare_suggestion(user_name, business_name, business_vn)
    "안녕하세요 #{user_name || '요양보호사'} 선생님\n#{business_name} 에서 요양보호사 근무를 제안하셨어요!\n\n일자리에 관심 있으시면, 아래 안심 번호로 연락부탁드려요!\n#{good_number(business_vn)}\n\n[ 근무제안에 응답하지 않으면 일자리 추천 순위가 낮아져요 ]"
  end

  def facility_proposal_1(user_name, business_name, business_vn)
    "안녕하세요 #{user_name || '요양보호사'} 선생님\n#{business_name} 에서 요양보호사 일자리를 제안하셨어요!\n\n근무 가능하신 선생님은 아래 안심 번호로 연락부탁드려요!\n#{good_number(business_vn)}\n\n[ 빠르게 연락할 수록 근무 가능성이 높아져요 ]"
  end

  def facility_proposal(user_name, business_name, business_vn)
    "안녕하세요 #{user_name || '요양보호사'} 선생님 (요양보호사 선생님)\n#{business_name} 에서 요양보호사 근무를 제안하셨어요!\n\n일자리에 관심 있으시면, 아래 안심 번호로 연락부탁드려요!\n#{good_number(business_vn)}\n\n[ 근무제안에 응답하지 않으면 일자리 추천 순위가 낮아져요]"
  end

  def good_number(phone_number)
    if phone_number&.length == 12
      phone_number&.scan(/.{4}/)&.join('-')
    else
      phone_number&.slice(0, 3) + "-" +  phone_number&.slice(3..)&.scan(/.{4}/)&.join('-') rescue nil
    end
  end
end
# frozen_string_literal: true

class Notification::Factory::NewNoneLtcRequest < Notification::Factory::NotificationFactoryClass
  include NotificationType
  include KakaoNotificationLoggingHelper

  def initialize(params)
    super(MessageTemplateName::NONE_LTC_REQUEST)
    @none_ltc_request = params
    raise "none ltc request #{none_ltc_request_id} not exists" unless @none_ltc_request

    create_message
  end

  def create_message
    params = {
      service: get_service_string(@none_ltc_request[:service]),
      date: @none_ltc_request[:created_at],
      link: 'http://pf.kakao.com/_jixkfG/chat'
    }

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @none_ltc_request[:phone_number],
        params,
        "",
        "AI"
      )
    )
  end

  private

  def get_service_string(service)
    case service
    when 1
      return "병원 동행"
    when 2
      return "방문 재활"
    when 3
      return "방문 돌봄"
    when 4
      return "입주 돌봄"
    end
  end
end

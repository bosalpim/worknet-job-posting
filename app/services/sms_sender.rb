# frozen_string_literal: true

class SmsSender
  include NotificationRequestHelper

  def self.call(
    to:,
    message:
  )
    new(
      to: to,
      message: message
    ).call
  end

  def initialize(to:, message:)
    @to = to
    @message = message
  end

  def call
    response = request_post_pay({
                                  msgid: "WEB#{Time.now.strftime("%y%m%d%H%M%S")}_#{SecureRandom.uuid.gsub('-', '')[0, 7]}",
                                  message_type: 'AT',
                                  receiver_num: @to.gsub(/[^0-9]/, ""),
                                  message: @message,
                                  profile_key: ENV['KAKAO_BIZMSG_PROFILE'],
                                  sender_num: '15885877',
                                  sms_kind: @message.bytesize.to_i > 90 ? 'L' : 'S',
                                  sms_only: 'Y',
                                  sms_message: @message,
                                  reserved_time: '00000000000000'
                                })
    response
  end
end

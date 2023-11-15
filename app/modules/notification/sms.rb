# frozen_string_literal: true

class Notification::Sms < Notification::Base
  def initialize(
    phone_number:,
    message:
  )
    @phone_number = phone_number
    @message = message
  end

  def send
    body = [{
              message_type: "AT",
              phn: @phone_number,
              profile: BIZMSG_PROFILE,
              msg: @message,
              smsKind: "S",
              msgSms: @message,
              smsOnly: "Y",
              smsSender: "15885877",
            }]
    begin
      response = HTTParty.post(
        "https://alimtalk-api.bizmsg.kr/v2/sender/send",
        body: JSON.dump(body),
        headers: {
          "userid" => "bosalpim21",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      )
      response = response[0]
      if response[:code] == "fail"
        raise "비즈엠 요청 실패 #{response}"
      end

      return response
    rescue => e
      Jets.logger.error e

      return nil
    end
  end
end


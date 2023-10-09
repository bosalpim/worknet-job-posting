module NotificationRequestHelper

  BIZ_MSG_BASE_URL = "https://alimtalk-api.sweettracker.net/v2/#{ENV['KAKAO_BIZMSG_PROFILE']}/sendMessage"
  def headers
    {
      "userid" => "bosalpim21",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def app_push_headers
    {
      Authorization: "key=#{ENV["FCM_APP_PUSH_AUTHORIZATION"]}",
      "Content-Type" => "application/json",
      "Accept" => "*/*"
    }
  end

  def app_push_user(users)
    return users.map do |user|
      user.push
    end
  end

  def request_app_push(request_params, target_public_id)
    begin
      response = HTTParty.post(
        "https://fcm.googleapis.com/fcm/send",
        body: JSON.dump(request_params),
        headers: app_push_headers,
        timeout: 10
      ).parsed_response

      response.class == Array ? response.first : response
      success = response[:success]
      if success == 1
        { status: 'success', response: response, target_public_id: target_public_id }
      else
        { status: 'fail', response: response, target_public_id: target_public_id }
      end
    rescue Net::ReadTimeout
      msg = "#{request_params} NET::TIMEOUT"
      Jets.logger.info msg
      { status: 'fail', response: "NET::TIMEOUT", target_public_id: target_public_id }
    rescue HTTParty::Error => e
      msg = "#{request_params} HTTParty::Error #{e.message}"
      Jets.logger.info msg
      { status: 'fail', response: "#{e.message}", target_public_id: target_public_id }
    end
  end

  def request_post_pay(request_params, target_public_id)
    begin
      response = HTTParty.post(
        BIZ_MSG_BASE_URL,
        body: JSON.dump([request_params]),
        headers: headers,
        timeout: 10
      ).parsed_response

      response = response.class == Array ? response.first : response
      # 일반 사용처를 위한 처리
      if target_public_id.nil?
        return response
      end
      { status: 'success', response: response, target_public_id: target_public_id }
    rescue Net::ReadTimeout
      msg = "#{request_params} NET::TIMEOUT"
      Jets.logger.info msg
      { status: 'fail', response: "NET::TIMEOUT", target_public_id: target_public_id }
    rescue HTTParty::Error => e
      msg = "#{request_params} HTTParty::Error #{e.message}"
      Jets.logger.info msg
      { status: 'fail', response: "#{e.message}", target_public_id: target_public_id }
    end
  end

  def request_pre_pay(request_params)
    response = HTTParty.post(
      "https://alimtalk-api.bizmsg.kr/v2/sender/send",
      body: JSON.dump([request_params]),
      headers: headers,
      timeout: 10
    ).parsed_response

    response.class == Array ? response.first : response
  end
end
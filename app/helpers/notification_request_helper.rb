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
  def request_app_push(request_params)
    response = HTTParty.post(
      "https://fcm.googleapis.com/fcm/send",
      body: JSON.dump(request_params),
      headers: app_push_headers,
      timeout: 10
    ).parsed_response

    response.class == Array ? response.first : response
  end

  def request_post_pay(request_params)
    response = HTTParty.post(
      BIZ_MSG_BASE_URL,
      body: JSON.dump([request_params]),
      headers: headers,
      timeout: 10
    ).parsed_response

    response.class == Array ? response.first : response
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
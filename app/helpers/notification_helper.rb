module NotificationHelper

  BIZ_MSG_BASE_URL = "https://alimtalk-api.sweettracker.net/v2/#{ENV['KAKAO_BIZMSG_PROFILE']}/sendMessage"
  def headers
    {
      "userid" => "bosalpim21",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end
end
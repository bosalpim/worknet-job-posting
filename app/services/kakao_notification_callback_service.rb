class KakaoNotificationCallbackService
  attr_reader :base_url, :user_id, :result_code, :callback_params

  def initialize(user_id, result_code, callback_params)
    @base_url = "#{ENV['API_URL']}/api/kakao_notification/callback"
    @user_id = user_id
    @result_code = result_code
    @callback_params = callback_params
  end

  def self.call(user_id:, result_code:, callback_params: {})
    new(user_id, result_code, callback_params).call
  end

  def call
    HTTParty.post(
      base_url,
      body: {
        user_id: user_id,
        result_code: result_code,
        **callback_params
      }
    )
  end
end
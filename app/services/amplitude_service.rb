class AmplitudeService
  include Singleton

  def initialize
    @end_point = "https://api2.amplitude.com/2/httpapi"
    @api_key = Jets.env.production? ? ENV['AMPLITUDE_PRODUCTION'] : ENV['AMPLITUDE_STAGING']
  end

  # target_public_id : 기관 또는 유저의 public_id
  # event_name : 이벤트 이름
  # event_properties : 이벤트 프로퍼티
  def log(event_name, event_properties, target_public_id)
    body = {
      "api_key" => @api_key,
      "events" => {
        "user_id" => target_public_id,
        "event_type" => event_name,
        "event_properties" => event_properties
      }
    }.to_json

    p 'cc'
    p body
    p 'dd'
    response = HTTParty.post(
      @end_point,
      body: body,
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "*/*",
      }
    )

    if response.dig("code") != 200
      Jets.logger.info "user_public_id: #{target_public_id} event: #{body} 로깅 실패"
    end
  end
end
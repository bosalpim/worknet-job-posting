class AmplitudeService
  include Singleton

  def initialize
    @end_point = "https://api2.amplitude.com/2/httpapi"
    @api_key = Jets.env.production? ? ENV['AMPLITUDE_PRODUCTION'] : ENV['AMPLITUDE_STAGING']
  end

  def log_array(array = [{user_id: nil, event_type: nil, event_properties: nil}])
    body = {
      "api_key" => @api_key,
      "events" => array
    }.to_json

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
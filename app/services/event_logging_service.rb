class EventLoggingService
  include Singleton

  def initialize
    setup_amplitude
    setup_mixpanel
  end

  private

  def setup_amplitude
    @amplitude_endpoint = "https://api2.amplitude.com/2/httpapi"
    @amplitude_api_key = Jets.env.production? ? ENV['AMPLITUDE_PRODUCTION'] : ENV['AMPLITUDE_STAGING']
  end

  def setup_mixpanel
    @mixpanel_endpoint = "https://api.mixpanel.com/track"
    @mixpanel_token = Jets.env.production? ? ENV['MIXPANEL_PRODUCTION'] : ENV['MIXPANEL_STAGING']
  end

  public

  def log_events(events = [{ user_id: nil, event_type: nil, event_properties: nil}])
    log_to_amplitude(events)
    log_to_mixpanel(events)
  end

  private

  def log_to_amplitude(events)
    body = {
      "api_key" => @amplitude_api_key,
      "events" => events
    }.to_json

    response = HTTParty.post(
      @amplitude_endpoint,
      body: body,
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "*/*",
      }
    )

    if response.dig("code") != 200
      Jets.logger.info "Amplitude event logging failed: #{body}"
    end
  end

  def log_to_mixpanel(events)
    events.each do |event|
      mixpanel_event = {
        "event" => event[:event_type],
        "properties" => {
          "token" => @mixpanel_token,
          "distinct_id" => event[:user_id],
        }.merge(event[:event_properties] || {})
      }

      response = HTTParty.post(
        @mixpanel_endpoint,
        body: [mixpanel_event].to_json,
        headers: {
          "Content-Type" => "application/json",
          "Accept" => "text/plain"
        }
      )

      Jets.logger.info({
        service: 'EventLoggingService',
        action: 'log_to_mixpanel',
        status: 'failed',
        event: mixpanel_event,
        response_code: response.code,
        response_body: response.body
      }.to_json)

      unless response.success?
        Jets.logger.info "Mixpanel event logging failed: #{mixpanel_event}"
      end
    end
  end
end
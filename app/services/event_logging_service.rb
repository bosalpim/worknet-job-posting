class EventLoggingService
  include Singleton

  def initialize
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
      event = event.transform_keys(&:to_sym)
      mixpanel_event = {
        "event" => event[:event_type],
        "properties" => {
          "token" => @mixpanel_token,
          "distinct_id" => event[:user_id],
        }.merge(event[:event_properties] || {})
      }

      begin
        response = HTTParty.post(
          @mixpanel_endpoint,
          body: [mixpanel_event].to_json,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "text/plain"
          }
        )

        if response.success?
          Jets.logger.info "Mixpanel event logged successfully: #{mixpanel_event}" if Jets.env != 'production'
        else
          Jets.logger.warn "Mixpanel event logging failed with status #{response.code}: #{response.body}" if Jets.env != 'production'
        end

      rescue HTTParty::Error => e
        Jets.logger.error "HTTParty error occurred: #{e.message}" if Jets.env != 'production'
      rescue SocketError => e
        Jets.logger.error "Network connection error: #{e.message}" if Jets.env != 'production'
      rescue StandardError => e
        Jets.logger.error "Unexpected error occurred while logging to Mixpanel: #{e.message}" if Jets.env != 'production'
      ensure
        Jets.logger.info "Mixpanel logging attempt finished for event: #{event[:event_type]}" if Jets.env != 'production'
      end
    end
  end
end
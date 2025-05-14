class SlackWebhookService
  attr_reader :webhook_type

  def self.call(webhook_type, payload)
    new(webhook_type).call(payload)
  end

  def initialize(webhook_type)
    @webhook_type = webhook_type
  end

  def call(payload)
    notifier = get_notifier
    p notifier
    return if notifier.nil? || notifier.endpoint.nil? # webhook_url이 없으면 아무것도 하지 않음
    notifier.post(payload)
  end

  private

  def get_notifier
    webhook_url = case webhook_type
    when :dev_alert
      ENV['SLACK_DEV_ALERT_URL']
    when :newspaper
      ENV['SLACK_NOTI_NEWSPAPER_URL']
    when :none_ltc_consulting_alert
      ENV['SLACK_NOTI_NONE_LTC_CONSULTING_ALERT']
    when :business_free_trial
      ENV['BUSINESS_FREE_TRIAL_ALERT']
    end
return nil if webhook_url.nil? || webhook_url.empty?
Slack::Notifier.new(webhook_url)
  end
end
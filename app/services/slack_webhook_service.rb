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
    notifier.post(payload)
  end

  private

  def get_notifier
    notifier = nil
    case webhook_type
    when :dev_alert
      notifier = Slack::Notifier.new(ENV['SLACK_DEV_ALERT_URL'])
    when :newspaper
      notifier = Slack::Notifier.new(ENV['SLACK_NOTI_NEWSPAPER_URL'])
    when :none_ltc_consulting_alert
      notifier = Slack::Notifier.new(ENV['SLACK_NOTI_NONE_LTC_CONSULTING_ALERT'])
    end
    notifier
  end
end
class CreateNewsPaperActivelyCommonMessageService < CreateScheduledMessageService
  include NewsPaper
  def initialize
    super(
      # 적극구직, 구직중 모두 적극구직 중 유저가 받는 신문으로 통일합니다.
      MessageTemplateName::NEWSPAPER_V2,
      NotificationResult::NEWS_PAPER
    )
  end

  def self.call
    new.call
  end

  def self.test_call
    new.test_call
  end

  def test_call
    data = create_message(User.where(phone_number: '01094659404').first!)
    return if data.nil?

    ScheduledMessageCount.create!(
      template_id: MessageTemplateName::NEWSPAPER_V2,
      total_count: 10
    )

    ScheduledMessage.create!(
      template_id: @template_id,
      send_type: @send_type,
      content: data.dig(:jsonb),
      phone_number: data.dig(:phone_number),
      scheduled_date: data.dig(:scheduled_date)
    )

    factory = Notification::Factory::SendNewsPaper.new(0.1, 0)
    factory.process
  end

  def call
    save_call { |user| create_message(user) }
  end

  def create_message(user)
    phone_number = user.phone_number
    should_app_push = user.is_sendable_app_push
    target_medium = should_app_push ? Notification::Factory::NotificationFactoryClass::APP_PUSH : Notification::Factory::NotificationFactoryClass::KAKAO_ARLIMTALK
    jsonb = { lat: user.lat, lng: user.lng, target_public_id: user.public_id, target_medium: target_medium }
    jsonb["push_token"] = user.push_token.token if should_app_push

    {
      phone_number: phone_number,
      jsonb: jsonb.to_json,
      scheduled_date: DateTime.now
    }
  end
end
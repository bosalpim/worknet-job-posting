class CreateNewsPaperActivelyCommonMessageService < CreateScheduledMessageService
  def initialize
    super(
      # 적극구직, 구직중 모두 적극구직 중 유저가 받는 신문으로 통일합니다.
      KakaoTemplate::JOB_ALARM_ACTIVELY,
      KakaoNotificationResult::NEWS_PAPER
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

    message = ScheduledMessage.create!(
      template_id: @template_id,
      send_type: @send_type,
      content: data.dig(:jsonb),
      phone_number: data.dig(:phone_number),
      scheduled_date: data.dig(:scheduled_date)
    )
    KakaoNotificationService.call(
      template_id: message.template_id,
      message_type: "AI",
      phone: Jets.env != 'production' ? '01094659404' : message.phone_number,
      template_params: JSON.parse(message.content)
    )
  end

  def call
    save_call { |user| create_message(user) }
  end

  def create_message(user)
    phone_number = user.phone_number
    jsonb = {}.to_json

    return {
      phone_number: phone_number,
      jsonb: jsonb,
      scheduled_date: DateTime.now
    }
  end
end
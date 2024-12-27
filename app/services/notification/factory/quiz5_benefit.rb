class Notification::Factory::Quiz5Benefit < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize
    super(MessageTemplateName::QUIZ_5_BENEFIT)

    @list = User.joins(:alerts, :user_push_tokens)
                .where(alerts: { name: 'quiz_5' })
                .distinct

    @batch_size = 20

    create_message
    send_log_batches
  end

  def create_message
    @list.each do |user |
      @log_data = []

      base_path = "quiz/daily-proverbs"

      user_push_token = user.user_push_tokens.first&.token

      if user_push_token&.present?
        link = "#{base_path}?utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=quiz-5-alert&referral=app_push"

        @log_data << {
          "user_id" => user.public_id,
          "event_type" => "[Action] Receive Notification",
          "event_properties" => {
            "template" => MessageTemplateName::QUIZ_5_BENEFIT,
            "sender_type" => SENDER_TYPE_CAREPARTNER,
            "receiver_type" => RECEIVER_TYPE_BUSINESS,
            "send_at" => Time.current + (9 * 60 * 60),
            "notiName" => "benefit_quiz_5",
            "itemId" => "quiz_5"
          }
        }
        if Jets.env.production?
          @app_push_list.push(
            AppPush.new(
              @message_template_id,
              user_push_token,
              nil,
              {
                title: "💡 퀴즈 풀고 15원 받기 알림 💡",
                body: "지금 우리말 속담을 맞춰보세요",
                link: "#{Main::Application::DEEP_LINK_SCHEME}/#{link}"
              },
              user.public_id,
              {
                "sender_type" => SENDER_TYPE_CAREPARTNER,
                "receiver_type" => RECEIVER_TYPE_USER,
                "template" => @message_template_id,
                "type" => NOTIFICATION_TYPE_APP_PUSH,
              }
            )
          )
        end
      end
    end
  end

  def send_log_batches
    return if @log_data.empty?

    batch_size = 2000
    @log_data.each_slice(batch_size) do |batch|
      AmplitudeService.instance.log_array(batch)
    end
  end
end
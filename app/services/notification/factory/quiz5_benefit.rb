class Notification::Factory::Quiz5Benefit < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize
    super(MessageTemplateName::QUIZ_5_BENEFIT)
    alert = Alert.find_by(name: 'quiz_5')

    @list = alert ? alert.users : []

    create_message
  end

  def create_message
    @list.each do |user |

      base_path = "benefit"

      # user_push_token = user.user_push_tokens.first&.token
      user_push_token = 'caZn4fHBSbyJ4GjYlXqrcj:APA91bFcki9uOKKUUZu1UhJlTjB64bQ9kMk6A_FJqCnj1iAQAoJdcgaL3swcXrfraOfcL-FWx5DsSEeHmFM4AJ5JaMLyyCi_xgPn-Rm447xI9egmDe8PF-k'

      if user_push_token&.present?
        link = "#{base_path}&utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=quiz-5-alert&referral=app_push"
        AmplitudeService.instance.log_array([{
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
                                             }])
        unless Jets.env.production?
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
end
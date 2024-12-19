class Notification::Factory::CoupangPartnersBenefit < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize
    super(MessageTemplateName::COUPANG_PARTNERS_BENEFIT)
    alert = Alert.find_by(name: 'coupang_partners')

    @list = alert ? alert.users : []

    create_message
  end

  def create_message
    @list.each do |user |

      base_path = "benefit/button-press"

      user_push_token = user.user_push_tokens.first&.token

      if user_push_token&.present?
        link = "#{base_path}&utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=button-press-alert"
        if Jets.env.production?
          @app_push_list.push(
            AppPush.new(
              @message_template_id,
              user_push_token,
              nil,
              {
                title: "👆 버튼 누르고 10원 받기 알림 👆",
                body: "지금 바로 포인트 10원 받을 수 있어요",
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
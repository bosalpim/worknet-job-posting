class Notification::Factory::CoupangPartnersBenefit < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize
    super(MessageTemplateName::COUPANG_PARTNERS_BENEFIT)

    @list = User.joins(:alerts, :user_push_tokens)
                .where(alerts: { name: 'coupang_partners' })
                .distinct

    Jets.logger.info "list: #{@list}"

    create_message
  end

  def create_message
    @list.each do |user |

      base_path = "benefit/button-press"

      user_push_token = user.user_push_tokens.first&.token

      if user_push_token&.present?
        link = "#{base_path}&utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=button-press-alert&referral=app_push"
        AmplitudeService.instance.log_array([{
                                               "user_id" => user.public_id,
                                               "event_type" => "[Action] Receive Notification",
                                               "event_properties" => {
                                                 "template" => MessageTemplateName::COUPANG_PARTNERS_BENEFIT,
                                                 "sender_type" => SENDER_TYPE_CAREPARTNER,
                                                 "receiver_type" => RECEIVER_TYPE_BUSINESS,
                                                 "send_at" => Time.current + (9 * 60 * 60),
                                                 "notiName" => "benefit_buttonclick",
                                                 "itemId" => "coupang partners"
                                               }
                                             }])
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
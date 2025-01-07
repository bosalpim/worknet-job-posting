class Notification::Factory::UserPushAlert < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize(user_push_alert_queues = UserPushAlertQueue.where(id: nil).limit(10), base_path = "", title = "", body = "", campaign_name = "")
    super(MessageTemplateName::USER_PUSH_ALERT)

    @list = user_push_alert_queues
    @base_path = base_path
    @title = title
    @body = body
    @campaign_name = campaign_name

    create_message
  end

  def create_message
    @list.each do |user_push_alert_queue|
      user = user_push_alert_queue.user

      if user_push_alert_queue.push_token&.present?
        link = "#{@base_path}&utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=#{@campaign_name}&referral=app_push"
        if Jets.env.production?
          @app_push_list.push(
            AppPush.new(
              @message_template_id,
              user_push_alert_queue.push_token,
              nil,
              {
                title: @title,
                body: @body,
                link: "#{Main::Application::DEEP_LINK_SCHEME}/#{link}"
              },
              user.public_id,
              {
                "sender_type" => SENDER_TYPE_CAREPARTNER,
                "receiver_type" => RECEIVER_TYPE_USER,
                "template" => @message_template_id,
                "type" => NOTIFICATION_TYPE_APP_PUSH,
                "campaign_name" => @campaign_name,
              }
            )
          )
        end
    end
    end
  end
end
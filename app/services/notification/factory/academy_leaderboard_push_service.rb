# frozen_string_literal: true

class Notification::Factory::AcademyLeaderboardPushService < Notification::Factory::NotificationFactoryClass
  include NotificationType
  include KakaoNotificationLoggingHelper

  def initialize(params)
    super(MessageTemplateName::ACADEMY_LEADERBOARD)
    @user_infos = params[:user_infos] # [{public_id: ..., token: ...}, ...]
  end

  def create_message
    Jets.logger.info "create_message"
    create_app_push_message if @target_medium == APP_PUSH
  end

  def create_app_push_message
    base_path = "/academy/leaderboard"
    title = "아카데미 학습 알림"
    campaign_name = "academy_leaderboard"
    body = "현재 학습 진행률이 50% 미만입니다. 학습을 계속 진행해주세요!"
    link = "#{base_path}?utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=#{campaign_name}&referral=app_push"

    @user_infos.each do |info|
      @app_push_list.push(
        AppPush.new(
          @message_template_id,
          info[:token],
          nil,
          {
            title: title,
            body: body,
            link: "#{Main::Application::DEEP_LINK_SCHEME}#{link}"
          },
          info[:public_id],
          {
            "sender_type" => SENDER_TYPE_CAREPARTNER,
            "receiver_type" => RECEIVER_TYPE_USER,
            "template" => @message_template_id,
            "type" => NOTIFICATION_TYPE_APP_PUSH,
            "campaign_name" => campaign_name,
          }
        )
      )
    end
  end
end

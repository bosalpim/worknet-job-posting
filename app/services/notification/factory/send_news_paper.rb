class Notification::Factory::SendNewsPaper < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper
  def initialize(should_send_percent, sent_percent)
    super(MessageTemplateName::NEWSPAPER_V2)
    @list = Notification::Factory::SearchTarget::GetNewsPaperScheduledMessage.call(@message_template_id, should_send_percent, sent_percent)
    # 신문 발송 App Push 가능함을 업데이트
    create_message
  end

  def create_message
    @list.each do |message|
      template_params = JSON.parse(message.content)
      # target_medium = template_params["target_medium"]
      # if target_medium == APP_PUSH
      #   push_token = template_params["push_token"]
      #   path = "/newspaper?lat=#{template_params["lat"]}&lng=#{template_params["lng"]}&utm_source=message&utm_medium=app_push&utm_campaign=newspaper_job_alarm"
      #   date = NewsPaper::get_today_date
      #   @app_push_list.push(
      #     AppPush.new(
      #       @message_template_id,
      #       push_token,
      #       nil,
      #       {
      #         title: "#{date} 우리동네 요양일자리 신문이 도착했어요!",
      #         body: "지금 바로 맞춤 일자리를 확인해보세요.",
      #         link: "#{DEEP_LINK_SCEHEME}#{path}"
      #       },
      #       template_params["target_public_id"],
      #       {
      #         "sender_type" => SENDER_TYPE_CAREPARTNER,
      #         "receiver_type" => RECEIVER_TYPE_USER,
      #         "template" => @message_template_id,
      #         "type" => NOTIFICATION_TYPE_APP_PUSH
      #       }
      #     )
      #   )
      # else
        @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, message.phone_number, template_params, template_params["target_public_id"], "AI"))
      # end
    end
  end
end
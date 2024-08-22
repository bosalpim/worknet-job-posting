class Notification::Factory::SendNewsPaperV2 < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize(newspapers = Newspaper.where(id: nil).limit(10))
    super(MessageTemplateName::NEWSPAPER_V2)

    @list = newspapers

    create_message
  end

  def create_message
    @list.each do |newspaper|
      user = newspaper.user

      if user&.lat.nil? || user&.lng.nil?
        next
      end

      # 신문 매일발송 그룹 나누기 위한 property 상수. 짝수면 실험군, 홀수면 대조군.
      allday_news_exp_group = if user.id.even?
                                "B"
                              else
                                "A"
                              end
      
      base_path = "newspaper?lat=#{user.lat}&lng=#{user.lng}&userId=#{user.public_id}"

      if newspaper.push_token&.present?
        link = "#{base_path}&utm_source=message&utm_medium=#{NOTIFICATION_TYPE_APP_PUSH}&utm_campaign=newspaper_job_alarm"
        if Jets.env.production?
          @app_push_list.push(
            AppPush.new(
              @message_template_id,
              newspaper.push_token,
              nil,
              {
                title: "우리동네 요양일자리 신문이 도착했어요!",
                body: "지금 바로 맞춤 일자리를 확인해보세요.",
                link: "#{Main::Application::DEEP_LINK_SCHEME}/#{link}"
              },
              user.public_id,
              {
                "sender_type" => SENDER_TYPE_CAREPARTNER,
                "receiver_type" => RECEIVER_TYPE_USER,
                "template" => @message_template_id,
                "type" => NOTIFICATION_TYPE_APP_PUSH,
                "allday_news_exp_group" => allday_news_exp_group,
              }
            )
          )
        end
      elsif user.phone_number.present?
        link = "https://www.carepartner.kr/#{base_path}&utm_source=message&utm_medium=arlimtalk&utm_campaign=newspaper_job_alarm"

        Jets.logger.info "arlimtalk send"

        if Jets.env.production?
          @bizm_post_pay_list.push(
            BizmPostPayMessage.new(
              @message_template_id,
              user.phone_number,
              {
                link: link
              },
              user.public_id,
              "AI",
              nil,
              [0]
            )
          )
        else
          Jets.logger.info BizmPostPayMessage.new(
            @message_template_id,
            user.phone_number,
            {
              link: link,
              allday_news_exp_group: allday_news_exp_group
            },
            user.public_id,
            "AI",
            nil,
            [0]
          )
        end
      end
    end
  end
end
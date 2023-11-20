class Notification::Factory::ProposalNotificationExpires < Notification::Factory::NotificationFactoryClass
  include KakaoNotificationLoggingHelper

  def initialize
    super(MessageTemplateName::PROPOSAL_NOTIFICATION_EXPIRES)
    @list = getTargetUsers
    create_message if @list.size > 0
  end

  private

  def formatDate(date, format)
    korean_offset = 9 * 60 * 60
    date = date + korean_offset
    date.strftime(format)
  end

  def getExpiresInfo(user)
    # 알리 종료 예정 날짜
    expires_date = formatDate(user.proposal_notification_expires_at, '%m월 %d일')
    # 알림 종료 예정 일시
    expires_date_with_time = formatDate(user.proposal_notification_expires_at, '%Y년 %m월 %d일 %p %I:%M').gsub('AM', '오전').gsub('PM', '오후')
    {
      expires_date: expires_date,
      expires_date_with_time: expires_date_with_time
    }
  end
  def create_app_push_message(user)
    expiresInfo = getExpiresInfo(user)
    app_push = AppPush.new(
      @message_template_id,
      user.push_token.token,
      @message_template_id,
      {
        title: "#{expiresInfo[:expires_date]}부터 요양센터로부터 전화면접 제안을 받을 수 없게 돼요.",
        body: "전화면접 제안 종료 예정시각: #{expiresInfo[:expires_date_with_time]}",
      },
      user.public_id,
      {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_USER,
        "template" => @message_template_id,
      })
    @app_push_list.push(app_push)
  end

  def create_bizm_post_pay_message(user)
    params = getExpiresInfo(user)

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, user.phone_number, params, user.public_id, "AI"))
  end
  def create_message
    @list.each do |user|
      if @target_medium == 'app_push'
        if user.is_sendable_app_push
          create_app_push_message(user)
        else
          create_bizm_post_pay_message(user)
        end
      else
        create_bizm_post_pay_message(user)
      end
    end
  end

  def getTargetUsers
    users = User.receive_proposal_notifications
    # 현재 시간으로부터 하루 이내에 만료되는 유저 조회
    users = users.where('proposal_notification_expires_at > ? AND proposal_notification_expires_at <= ?', Time.current, 1.day.from_now)
    users
  end

end

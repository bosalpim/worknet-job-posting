class UserPushAlertQueueTransmitJob < ApplicationJob
  include Jets::AwsServices
  include MessageTemplateName
  include KakaoNotificationLoggingHelper

  def send_push(alert_name, user_push_queue)
    case alert_name
    when "quiz_5"
      factory = Notification::Factory::UserPushAlert.new(user_push_queue.processing,
                                                         base_path = "/quiz/daily-proverbs",
                                                         title = "💡퀴즈 풀고 포인트 받기 알림💡",
                                                         body = "지금 우리말 속담을 맞춰보세요",
                                                         campaign_name = "quiz-5-alert")
    when "yoyang_run"
      factory = Notification::Factory::UserPushAlert.new(user_push_queue.processing,
                                                         base_path = "/benefit/games/yoyang-run",
                                                         title = "🐱 게임하고 포인트 무제한 받기",
                                                         body = "지금 달려라 요양이 게임 한판 해보세요",
                                                         campaign_name = "yoyang-run-alert")
    when "daily_chinese_zodiac_fortune"
      factory = Notification::Factory::UserPushAlert.new(user_push_queue.processing,
                                                         base_path = "/czf",
                                                         title = "🍀 오늘의 띠별 운세 🍀",
                                                         body = "내 띠에 맞는 운세 보고 행운 받아가세요",
                                                         campaign_name = "zodiac-fortune-alert")
    when "7_daily_check_in"
      factory = Notification::Factory::UserPushAlert.new(user_push_queue.processing,
                                                         base_path = "/benefit/seven-daily-check-in",
                                                         title = "🥃 박카스 받기 미션 🥃",
                                                         body = "매일 출석체크하고 박카스 받으세요!",
                                                         campaign_name = "7-daily-check-in-alert")
    when "coupang_roulette"
      factory = Notification::Factory::UserPushAlert.new(user_push_queue.processing,
                                                         base_path = "/benefit/roulette",
                                                         title = "룰렛 돌리고 랜덤 주머니 받기",
                                                         body = "시간 지나면 당첨 기회가 사라져요!",
                                                         campaign_name = "coupang-roulette")
    when "academy_boost"
      # 유저별로 맞춤 메시지를 생성
      message_map = {}
      user_push_queue.processing.each do |queue|
        user = queue.user
        user_data = queue.user_data
        days_since_start = user_data["days_since_enrollment"] if user_data.present?
        course_id = user_data["course_id"] if user_data.present?
        title = case days_since_start
        when 1
          "동기 수강생의 90%가 이미 강의 듣기 시작했어요."
        when 2
          "동기 수강생 이번주 Top10은 모두 진도율 20% 달성!"
        when 3
          "동기 수강생 이번주 Top10은 모두 진도율 30% 달성!"
        when 4
          "동기 수강생 이번주 Top10은 모두 진도율 35% 달성!"
        when 5
          "동기 수강생 이번주 Top10은 모두 진도율 40% 달성!"
        when 6
          "동기 수강생 이번주 Top10은 모두 진도율 45% 달성!"
        when 7
          "동기 수강생 이번주 Top10은 모두 진도율 50% 달성!"
        else
          nil
        end

        # 7일차 이후에는 푸시를 보내지 않음
        next if title.nil?

        body = "#{user.name}님도 도전해보세요!"
        
        # queue별 맞춤 메시지 저장
        message_map[queue.id] = { title: title, body: body }
      end

      # 모든 queue에 대해 한 번에 factory 생성
      factory = Notification::Factory::UserPushAlert.new(
        user_push_queue.processing,
        base_path = "/academy/my/#{course_id}",
        title = "",  # message_map에서 가져올 예정
        body = "",   # message_map에서 가져올 예정
        campaign_name = "academy-boost-alert",
        message_map = message_map
      )
    else
      Jets.logger.info "alert Name not found"
      return
    end
    factory.notify
    factory.save_result
  end

  iam_policy 'sqs'
  sqs_event Jets.env.production? ? "user_push_job_queue.fifo" : "user_push_job_queue_stag.fifo"

  # queue에서 순차적으로 보내온 이벤트를 처리하는 job입니다
  def execute
    Jets.logger.info "#{JSON.dump(event)}"

    payload = sqs_event_payload

    Jets.logger.info "#{payload}"

    group = payload.dig(:group)
    date = payload.dig(:date)
    alert_name = payload.dig(:alert_name)

    alert = Alert.where(name: alert_name).first

    user_push_queue = UserPushAlertQueue
                        .where(
                          alert_id: alert.id,
                          date: date,
                          group: group,
                          )
                        .joins(:user)
                        .limit(3_000)

    if user_push_queue.empty?
      Jets.logger.info "[Alert=#{alert_name} DATE=#{date}, GROUP=#{group}] 발송 완료"
      return
    end

    user_push_queue.pending.update_all(status: 'processing')

    Jets.logger.info "Alert=#{alert_name} [DATE=#{date}, GROUP=#{group}] #{user_push_queue.processing.length}건 발송 시작"

    send_push(alert_name, user_push_queue)

    Jets.logger.info "[Alert=#{alert_name} DATE=#{date}, GROUP=#{group}] #{user_push_queue.processing.length}건 발송 종료"

    updated_count = user_push_queue.processing.update_all(status: 'done')

    Jets.logger.info "[Alert=#{alert_name} DATE=#{date}, GROUP=#{group}] #{updated_count}건 처리 완료"

    next_group = group + 1
    sqs.send_message(
      queue_url: Main::USER_PUSH_JOB_QUEUE_URL,
      message_group_id: "push-#{alert_name}-#{date}",
      message_deduplication_id: "push-#{alert_name}-#{date}-#{next_group}",
      message_body: JSON.dump({
                                alert_name: alert_name,
                                date: date,
                                group: next_group
                              })
    )
  end

end

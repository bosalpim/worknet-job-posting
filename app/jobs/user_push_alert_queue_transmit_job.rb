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

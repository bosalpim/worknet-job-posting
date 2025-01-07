# frozen_string_literal: true

class UserPushAlertQueueStartJob < ApplicationJob
  include Jets::AwsServices

  # user_push_alert_queues table에 있는 데이터를 바탕으로 첫 sqs queue를 생성하는 job입니다
  # 메세지 보내는 시간에 맞춰서 실행합니다.

  iam_policy 'sqs'
  cron "50 9 * * ? *"
  def start_send_coupang_partners
    start_send_sqs("coupang_partners")
  end

  iam_policy 'sqs'
  cron "30 23 * * ? *"
  def start_send_quiz_5
    start_send_sqs("quiz_5")
  end

  iam_policy 'sqs'
  cron "15 10 * * ? *"
  def start_send_yoyang_run_push
    start_send_sqs("yoyang_run")
  end

  def start_send_sqs(alert_name)
    date = DateTime.now.at_beginning_of_day.strftime('%Y/%m/%d')
    group = 0
    sqs.send_message(
      queue_url: Main::USER_PUSH_JOB_QUEUE_URL,
      message_group_id: "push-#{alert_name}-#{date}",
      message_deduplication_id: "push-#{alert_name}-#{date}-#{group}",
      message_body: JSON.dump({
                                alert_name: alert_name,
                                date: date,
                                group: group
                              })
    )
  end

end

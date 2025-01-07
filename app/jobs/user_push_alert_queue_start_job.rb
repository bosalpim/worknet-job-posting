# frozen_string_literal: true

class UserPushAlertQueueStartJob < ApplicationJob
  include Jets::AwsServices
  # 월요일 오전 10시 발송 시작
  iam_policy 'sqs'

  cron "55 7 * * ? *"
  def start_send_yoyang_run_push
    start_send_sqs("yoyang_run")
  end

  def start_send_sqs(alert_name)
    date = DateTime.now.at_beginning_of_day.strftime('%Y/%m/%d')
    group = 0
    sqs.send_message(
      queue_url: Main::USER_PUSH_JOB_QUEUE_URL,
      message_group_id: "#{alert_name}-#{date}",
      message_deduplication_id: "#{alert_name}-#{date}-#{group}",
      message_body: JSON.dump({
                                alert_name: alert_name,
                                date: date,
                                group: group
                              })
    )
  end

end

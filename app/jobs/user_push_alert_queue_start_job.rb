# frozen_string_literal: true

class UserPushAlertQueueStartJob < ApplicationJob
  include Jets::AwsServices
  # 월요일 오전 10시 발송 시작
  iam_policy 'sqs'

  cron "0 4 * * ? *"
  def start_send_yoyang_run_push
    date = DateTime.now.at_beginning_of_day.strftime('%Y/%m/%d')
    alert = Alert.where(name: 'yoyang_run').first
    group = 0
    sqs.send_message(
      queue_url: Main::USER_PUSH_JOB_QUEUE_URL,
      message_group_id: "#{alert.id}-#{date}",
      message_deduplication_id: "#{alert.id}-#{date}-#{group}",
      message_body: JSON.dump({
                                alert_id: alert.id,
                                date: date,
                                group: group
                              })
    )
  end

end

# frozen_string_literal: true

class StartSendNewspaperJob < ApplicationJob
  include Jets::AwsServices
  # 월요일 오전 10시 발송 시작
  iam_policy 'sqs'
  cron "0 1 ? * MON *"

  def start_send_monday_newspaper
    date = DateTime.now.strftime("%Y/%m/%d")
    group = 0
    sqs.send_message(
      queue_url: Main::NEWSPAPER_JOB_QUEUE_URL,
      message_group_id: date,
      message_deduplication_id: "#{date}-#{group}",
      message_body: JSON.dump({
                                date: date,
                                group: group
                              })
    )
  end

  # 목요일 오전 10시 발송 시작
  iam_policy 'sqs'
  cron "0 1 ? * THU *"

  def create_send_thursday_newspaper
    date = DateTime.now.strftime("%Y/%m/%d")
    group = 0
    sqs.send_message(
      queue_url: Main::NEWSPAPER_JOB_QUEUE_URL,
      message_group_id: date,
      message_deduplication_id: "#{date}-#{group}",
      message_body: JSON.dump({
                                date: date,
                                group: group
                              })
    )
  end

  # 매일 보내는 신문 실험. 화수금 오전 10시 발송 시작
  iam_policy 'sqs'
  cron "0 1 ? * TUE,WED,FRI *"

  def create_allday_newspaper
    date = DateTime.now.strftime("%Y/%m/%d")
    group = 0
    sqs.send_message(
      queue_url: Main::NEWSPAPER_JOB_QUEUE_URL,
      message_group_id: date,
      message_deduplication_id: "#{date}-#{group}",
      message_body: JSON.dump({
                                date: date,
                                group: group
                              })
    )
  end

  # 재발송을 위한 임시 발송
  iam_policy 'sqs'
  cron "0 4 ? * THU *"

  def create_temp_retry_newspaper
    date = DateTime.now.strftime("%Y/%m/%d")
    group = 5
    sqs.send_message(
      queue_url: Main::NEWSPAPER_JOB_QUEUE_URL,
      message_group_id: date,
      message_deduplication_id: "#{date}-#{group}",
      message_body: JSON.dump({
                                date: date,
                                group: group
                              })
    )
  end
end

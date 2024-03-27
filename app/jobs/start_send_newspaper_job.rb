# frozen_string_literal: true

class StartSendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  # def initialize(event, context, meth)
  #   super
  # end

  # 월요일 오전 10시 발송 시작
  cron "0 20 ? * SUN *"

  def start_send_monday_newspaper
    date = DateTime.now.yesterday.strftime("%Y/%m/%d")
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
  cron "55 6 ? * WED *"

  def create_send_thursday_newspaper
    date = DateTime.now.yesterday.strftime("%Y/%m/%d")
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
end

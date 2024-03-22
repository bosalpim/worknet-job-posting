# frozen_string_literal: true

class StartSendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  # def initialize(event, context, meth)
  #   super
  # end

  # 월요일 오전 10시 발송 시작
  cron "0 20 ? * SUN *"

  def start_send_monday_newspaper
    queue_url = NewspaperJobQueue.lookup(:newspaper_job_queue_url)

    sqs.send_message(
      queue_url: queue_url,
      message_body: {
        date: DateTime.now.yesterday.strftime("%Y/%m/%d"),
        group: 0
      }
    )
  end

  # 목요일 오전 10시 발송 시작
  cron "0 20 ? * WED *"

  def create_send_thursday_newspaper
    queue_url = NewspaperJobQueue.lookup(:newspaper_job_queue_url)

    sqs.send_message(
      queue_url: queue_url,
      message_body: {
        date: DateTime.now.yesterday.strftime("%Y/%m/%d"),
        group: 0
      }
    )
  end
end

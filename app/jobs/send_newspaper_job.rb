class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices
  include MessageTemplateName

  iam_policy 'sqs'
  sqs_event Jets.env.production? ? "newspaper_job_queue.fifo" : "newspaper_job_queue_stag.fifo"

  def execute
    Jets.logger.info "#{JSON.dump(event)}"

    payload = sqs_event_payload

    Jets.logger.info "#{payload}"

    group = payload.dig(:group)
    date = payload.dig(:date)

    newspapers = Newspaper
                   .where(
                     date: date,
                     group: group,
                   )
                   .joins(:user)
                   .limit(3_000)

    if newspapers.empty?
      Jets.logger.info "[DATE=#{date}, GROUP=#{group}] 발송 완료"
      return
    end

    newspapers.pending.update_all(status: 'processing')

    Jets.logger.info "[DATE=#{date}, GROUP=#{group}] #{newspapers.processing.length}건 발송 시작"

    if Jets.env.production?
      if user.id.even?
        factory = Notification::Factory::SendNewsPaperV3.new(newspapers.processing)
      else
        factory = Notification::Factory::SendNewsPaperV2.new(newspapers.processing)
      end
      factory.notify
      factory.save_result
    end

    Jets.logger.info "[DATE=#{date}, GROUP=#{group}] #{newspapers.processing.length}건 발송 종료"

    updated_count = newspapers.processing.update_all(status: 'done')

    Jets.logger.info "[DATE=#{date}, GROUP=#{group}] #{updated_count}건 처리 완료"

    next_group = group + 1
    sqs.send_message(
      queue_url: Main::NEWSPAPER_JOB_QUEUE_URL,
      message_group_id: date,
      message_deduplication_id: "#{date}-#{next_group}",
      message_body: JSON.dump({
                                date: date,
                                group: next_group
                              })
    )
  end
end

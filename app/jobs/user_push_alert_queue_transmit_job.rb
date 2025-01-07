class UserPushAlertQueueTransmitJob < ApplicationJob
  include Jets::AwsServices
  include MessageTemplateName

  iam_policy 'sqs'
  sqs_event Jets.env.production? ? "user_push_job_queue.fifo" : "user_push_job_queue_stag.fifo"

  def execute
    Jets.logger.info "#{JSON.dump(event)}"

    payload = sqs_event_payload

    Jets.logger.info "#{payload}"

    group = payload.dig(:group)
    date = payload.dig(:date)
    alert_id = payload.dig(:alert_id)

    user_push_queue = UserPushAlertQueue
                   .where(
                     alert_id: alert_id,
                     date: date,
                     group: group,
                     )
                   .joins(:user)
                   .limit(3_000)

    if user_push_queue.empty?
      Jets.logger.info "[Alert=#{alert_id} DATE=#{date}, GROUP=#{group}] 발송 완료"
      return
    end

    user_push_queue.pending.update_all(status: 'processing')

    Jets.logger.info "Alert=#{alert_id} [DATE=#{date}, GROUP=#{group}] #{user_push_queue.processing.length}건 발송 시작"

    if Jets.env.production?
      factory = Notification::Factory::SendNewsPaperV2.new(user_push_queue.processing)
      factory.notify
      factory.save_result
    end

    Jets.logger.info "[Alert=#{alert_id} DATE=#{date}, GROUP=#{group}] #{user_push_queue.processing.length}건 발송 종료"

    updated_count = user_push_queue.processing.update_all(status: 'done')

    Jets.logger.info "[Alert=#{alert_id} DATE=#{date}, GROUP=#{group}] #{updated_count}건 처리 완료"

    next_group = group + 1
    sqs.send_message(
      queue_url: Main::USER_PUSH_JOB_QUEUE_URL,
      message_group_id: "#{alert_id}-#{date}",
      message_deduplication_id: "#{alert_id}-#{date}-#{next_group}",
      message_body: JSON.dump({
                                alert_id: alert_id,
                                date: date,
                                group: next_group
                              })
    )
  end
end

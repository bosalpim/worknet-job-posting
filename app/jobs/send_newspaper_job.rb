class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices
  include MessageTemplateName

  sqs_event "newspaper_job_queue"

  def execute
    Jets.logger.info "#{JSON.dump(event)}"

    payload = sqs_event_payload

    Jets.logger.info "#{payload}"

    group = payload.dig(:group)
    date = payload.dig(:date)

    template_id = NEWSPAPER_V2

    newspapers = Newspaper
                   .where(
                     date: date,
                     group: group
                   )
                   .includes(:user)
                   .limit(3_000)

    if newspapers.empty?
      Jets.logger.info "[DATE=#{date}, GROUP=#{group}] 발송 완료"
      return
    end

    newspapers.each_slice(5) do |slice|
      factory = Notification::Factory::SendNewsPaperV2.new(slice)
      factory.notify
      factory.save_result
    end

    sqs.send_message(
      queue_url: Main::NEWSPAPER_JOB_QUEUE_URL,
      message_body: "#{JSON.dump({ group: group + 1, date: date })}"
    )
  end
end

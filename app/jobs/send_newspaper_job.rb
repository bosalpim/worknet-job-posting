class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  sqs_event "newspaper_job_queue"

  def execute

    Jets.logger.info "#{JSON.dump(@sqs_event_payload)}"

    group = @sqs_event_payload.dig(:group)
    date = @sqs_event_payload.dig(:date)

    newspapers = Newspaper
                   .where(
                     date: date,
                     group: group
                   )
                   .limit(3_000)

    Jets.logger.info "#{newspapers.length}개 확인"
  end
end

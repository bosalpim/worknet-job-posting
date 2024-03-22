class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  sqs_event "newspaper_job_queue"

  def execute

    Jets.logger.info "#{JSON.dump(@sqs_event_payload)}"

    message = event[0]

    if message.nil?

    end

    date = message[:date]
    group = message[:group]

    newspapers = Newspaper
                   .where(
                     date: date,
                     group: group
                   )
                   .limit(3_000)

    Jets.logger.info "#{newspapers.length}개 확인"
  end
end

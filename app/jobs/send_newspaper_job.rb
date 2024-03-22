class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  class_timeout 900

  depends_on :newspaper_stack

  sqs_event ref(:newspaper_job_queue)

  def execute

    Jets.logger.info "#{JSON.dump(event)}"

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

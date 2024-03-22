class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  class_timeout 900
  
  depends_on :newspaper

  sqs_event ref(:newspaper_job_queue)

  def execute

    Jets.logger.info "#{JSON.dump(event)}"

    message = event[0]

    if message.nil?

    end

    group = message[:group]
    invoke_time = DateTime.parse(message[:invoke_time])
  end
end

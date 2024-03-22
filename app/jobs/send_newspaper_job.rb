class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices

  depends_on :newspaper_job_queue

  sqs_event ref(:newspaper_job_queue)

  def execute
    Jets.logger.info "#{JSON.dump(event)}"
  end
end

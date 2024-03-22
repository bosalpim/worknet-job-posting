class SendNewspaperJob < ApplicationJob
  include Jets::AwsServices
  class_timeout 1500 # 초

  depends_on :newspaper_job_queue

  sqs_event ref(:newspaper_job_queue)

  def execute
    Jets.logger.info "#{JSON.dump(event)}"
  end
end

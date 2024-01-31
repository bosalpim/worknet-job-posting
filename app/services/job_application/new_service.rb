# frozen_string_literal: true

class JobApplication::NewService
  include JobPostingsHelper
  include JobMatchHelper
  include NotificationType

  def initialize(
    job_application_public_id:
  )
    @job_application = JobApplication.find_by(
      public_id: job_application_public_id
    )
  end

  def call
    Notification::FactoryService.create(
      MessageTemplateName::JOB_APPLICATION,
      {
        job_application_id: @job_application.id
      }
    )
  end
end

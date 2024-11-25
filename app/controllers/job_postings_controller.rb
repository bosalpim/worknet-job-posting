class JobPostingsController < ApplicationController
  include Translation
  include JobPostingsHelper

  def create
    GetWorknetJobService.call
    render json: {
      success: true
    }, status: :ok
  end

  def job_ads_messages
    event = { job_posting_id: params["id"] }
    JobPostingJob.perform_later(:first_message, event)

    render json: {
      success: true
    }, status: :ok
  end
  def notify_matched_user
    event = {
      messages: params["messages"] || []
    }
    rsp = nil
    rsp = NotifyMatchedUserJob.perform_now(:process, event)

    render json: Jets.env.production? ? { success: true } : rsp, status: :ok
  end

  def new_saved_job_posting_user
    event = params
    rsp = nil

    notification = Notification::FactoryService.create(MessageTemplateName::CALL_SAVED_JOB_CAREGIVER, event)
    notification.notify
    notification.save_result

    render json: { success: true }, status: :ok
  end
end

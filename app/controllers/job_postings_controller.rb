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

  def new_satisfaction_survey
    event = { job_posting_id: params["id"] }
    rsp = nil
    rsp = NewSatisfactionSurveyJob.perform_now(:dig, event) if Jets.env.development?
    NewSatisfactionSurveyJob.perform_later(:dig, event) unless Jets.env.development?
    render json: Jets.env.production? ? { success: true } : rsp, status: :ok
  end

  def new_user_satisfaction_survey
    event = { job_posting_id: params["id"], user_id: params["user_id"] }
    rsp = nil
    rsp = NewUserSatisfactionSurveyJob.perform_now(:dig, event) if Jets.env.development?
    NewUserSatisfactionSurveyJob.perform_later(:dig, event) unless Jets.env.development?
    render json: Jets.env.production? ? { success: true } : rsp, status: :ok
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

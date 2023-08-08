class JobPostingsController < ApplicationController
  include Translation
  include JobPostingsHelper

  def create
    GetWorknetJobService.call
    render json: {
      success: true
    }, status: :ok
  end

  def new_notification
    event = { job_posting_id: params["job_posting_id"] }
    NewJobNotificationJob.perform_now(:dig, event) if Jets.env.development?
    NewJobNotificationJob.perform_later(:dig, event) unless Jets.env.development?
    render json: {
      success: true
    }, status: :ok
  end

  def new_satisfaction_survey
    event = { job_posting_id: params["job_posting_id"] }
    rsp = nil
    rsp = NewSatisfactionSurveyJob.perform_now(:dig, event) if Jets.env.development?
    NewSatisfactionSurveyJob.perform_later(:dig, event) unless Jets.env.development?
    render json: Jets.env.production? ? { success: true } : rsp, status: :ok
  end

  def new_user_satisfaction_survey
    event = { job_posting_id: params["job_posting_id"], user_id: params["user_id"] }
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

end

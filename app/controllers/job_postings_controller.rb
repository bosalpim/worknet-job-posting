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
    event = { job_posting_id: params["job_posting_id"], user_id: params["user_id"] }
    rsp = nil
    rsp = NewSatisfactionSurveyJob.perform_now(:dig, event) if Jets.env.development?
    rsp = NewSatisfactionSurveyJob.perform_later(:dig, event) unless Jets.env.development?
    render json: rsp, status: :ok
  end
end

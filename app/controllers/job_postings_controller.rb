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
    # 요보사:신규 일자리 알림
    NotificationServiceJob.perform_now(:notify, { message_template_id: MessageTemplateName::NEW_JOB_POSTING, params: { job_posting_id: event[:job_posting_id] } }) if Jets.env.development?
    NotificationServiceJob.perform_later(:notify, { message_template_id: MessageTemplateName::NEW_JOB_POSTING, params: { job_posting_id: event[:job_posting_id] } }) unless Jets.env.development?

    render json: {
      success: true
    }, status: :ok
  end

  def job_ads_messages
    event = { job_posting_id: params["job_posting_id"] }
    JobPostingJob.perform_later(:first_message, event)

    render json: {
      success: true
    }, status: :ok
  end

  def call_interview_proposal
    event = { proposal_id: params["proposal_id"] }
    rsp = nil
    rsp = SendCallInterviewProposal
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

  def new_saved_job_posting_user
    event = params
    rsp = nil

    notification = Notification::FactoryService.create(MessageTemplateName::CALL_SAVED_JOB_CAREGIVER, event)
    notification.notify
    notification.save_result

    render json: { success: true }, status: :ok
  end
end

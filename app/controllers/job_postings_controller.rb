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
    NotificationServiceJob.perform_now(:notify, { message_template_id: MessageTemplateName::NEW_JOB_POSTING, params: { job_posting_id: event[:job_posting_id] } }) if Jets.env.development?
    NotificationServiceJob.perform_later(:notify, { message_template_id: MessageTemplateName::NEW_JOB_POSTING, params: { job_posting_id: event[:job_posting_id] } }) unless Jets.env.development?
    render json: {
      success: true
    }, status: :ok
  end

  def job_ads_messages
    begin
      # 발송 데이터 생성
      notification = Notification::FactoryService.create(MessageTemplateName::NEW_JOB_POSTING, { job_posting_id: params["job_posting_id"] })
      notification.process

      # 1차 메세지 발송 완료 히스토리 & 2차 예약 히스토리 생성
      MessageHistory.create!(type_name: "completed", notification_relate_instance_types_id: 1, notification_relate_instance_id: params["job_posting_id"])
      MessageHistory.create!(type_name: "reserved", notification_relate_instance_types_id: 1, notification_relate_instance_id: params["job_posting_id"], scheduled_at: Time.current.tomorrow.beginning_of_day + 8.hours)

      # 2차 메세지 예약 알림톡 발송
      # notification = Notification::FactoryService.create(MessageTemplateName::NEW_JOB_POSTING, { job_posting_id: params["job_posting_id"] })
      # notification.process

      render json: {
        success: true
      }, status: :ok
    rescue => e
      console.error(e)
    end
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

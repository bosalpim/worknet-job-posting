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
      american_time = Time.current
      korean_offset = 9 * 60 * 60 # 9 hours ahead of American time
      korean_time = american_time + korean_offset

      # 발송 데이터 생성
      notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_FIRST, { job_posting_id: params["job_posting_id"] })
      notification.process

      # 1차 메세지 발송 완료 히스토리 & 2차 예약 히스토리 생성
      MessageHistory.create!(type_name: "completed", status: 1, notification_relate_instance_types_id: 1, notification_relate_instance_id: params["job_posting_id"])
      # 1차가 내일 오전8시로 예약된다면, 2차 발송 예약 시간은 2일뒤가 되어야한다.
      scheduled_at = Time.current.tomorrow.beginning_of_day + 8.hours
      scheduled_at = scheduled_at + 1.days if korean_time.hour > 21
      MessageHistory.create!(type_name: "reserved", status: 2, notification_relate_instance_types_id: 1, notification_relate_instance_id: params["job_posting_id"], scheduled_at: scheduled_at)

      # 2차 메세지 예약 알림톡 발송
      reserve_notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_RESERVE, { job_posting_id: params["job_posting_id"], times: 2, scheduled_at_text: (scheduled_at + korean_offset).strftime('%m월 %d일 %I시 %M분') })
      reserve_notification.process

      render json: {
        success: true
      }, status: :ok
    rescue => e
      Jets.logger.info "#{e.message}"
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

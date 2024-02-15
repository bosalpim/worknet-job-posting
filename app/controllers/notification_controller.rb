# frozen_string_literal: true

class NotificationController < ApplicationController
  include MessageTemplateName

  def send_message
    begin
      case params[:template]
      when BUSINESS_JOB_POSTING_COMPLETE
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: BUSINESS_JOB_POSTING_COMPLETE,
            params: { job_posting_id: params[:job_posting_id] }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: BUSINESS_JOB_POSTING_COMPLETE,
            params: { job_posting_id: params[:job_posting_id] }
          }) unless Jets.env.development?
      when SMART_MEMO
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: SMART_MEMO,
            params: {
              job_posting_id: params[:job_posting_id],
              user_id: params[:user_id],
              job_postings_connect_id: params[:job_postings_connect_id],
              call_record_id: params[:call_record_id],
              bizcall_callback_id: params[:bizcall_callback_id]
            }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: SMART_MEMO,
            params: {
              job_posting_id: params[:job_posting_id],
              user_id: params[:user_id],
              job_postings_connect_id: params[:job_postings_connect_id],
              call_record_id: params[:call_record_id],
              bizcall_callback_id: params[:bizcall_callback_id]
            }
          }) unless Jets.env.development?
      when TARGET_USER_JOB_POSTING
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: TARGET_USER_JOB_POSTING,
            params: {
              job_posting_id: event[:job_posting_id],
              distance: params["distance"],
              gender: params["gender"]
            }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: TARGET_USER_JOB_POSTING,
            params: {
              job_posting_id: event[:job_posting_id],
              distance: params["distance"],
              gender: params["gender"]
            }
          }) unless Jets.env.development?
      else
        Jets.logger.info "#{params} 요청 대응 case 추가 필요"
      end

      render json: {
        success: true
      }, status: :ok
    rescue => e
      Jets.logger.info "#{params}, Error: #{e.message}"
      render json: {
        success: true
      }, status: :ok
    end
  end

  def ask_active
    Notification::AskActiveService.new(ask_active_params).call
  end

  def ask_active_params
    params.permit(
      :url,
      :user_public_id,
      :user_name,
      :user_phone_number,
      :business_name,
      :job_posting_public_id,
      :job_posting_title)
  end
end
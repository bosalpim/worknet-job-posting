# frozen_string_literal: true

class NotificationController < ApplicationController
  include MessageTemplateName

  def sms
    to = if Jets.env.production?
           params[:to]
         else
           Main::Application::PHONE_NUMBER_WHITELIST.include?(params[:to]) ?
             params[:to] : Main::Application::TEST_PHONE_NUMBER
         end

    message = params[:message]

    response = SmsSender.call(
      to: to,
      message: message
    )

    render json: {
      success: response.dig("result") == 'Y',
    }, status: :ok
  end

  def send_message

    Jets.logger.info '---PARAMS---'
    Jets.logger.info params
    
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
              job_posting_id: params[:job_posting_id],
            }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: TARGET_USER_JOB_POSTING,
            params: {
              job_posting_id: params[:job_posting_id],
            }
          }) unless Jets.env.development?
      when TARGET_USER_JOB_POSTING_V2
        meth = :notify
        event = {
          message_template_id: TARGET_USER_JOB_POSTING_V2,
          params: {
            job_posting_id: params[:job_posting_id],
          }
        }
        Jets.env.development? ? NotificationServiceJob.perform_now(meth, event)
          : NotificationServiceJob.perform_later(meth, event)
      when TARGET_JOB_POSTING_AD
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: TARGET_JOB_POSTING_AD,
            params: {
              job_posting_id: params[:job_posting_id],
              count: params[:count]
            }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: TARGET_JOB_POSTING_AD,
            params: {
              job_posting_id: params[:job_posting_id],
              count: params[:count]
            }
          }) unless Jets.env.development?
      when JOB_SUPPORT_REQUEST_AGREEMENT
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: JOB_SUPPORT_REQUEST_AGREEMENT,
            params: {
              job_posting_id: params[:job_posting_id],
              user_id: params[:user_id]
            }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: JOB_SUPPORT_REQUEST_AGREEMENT,
            params: {
              job_posting_id: params[:job_posting_id],
              user_id: params[:user_id]
            }
          }) unless Jets.env.development?
      when TARGET_JOB_POSTING_AD_APPLY
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: TARGET_JOB_POSTING_AD_APPLY,
            params: {
              job_posting_id: params[:job_posting_id],
              user_id: params[:user_id],
              application_type: params[:application_type],
              job_application_id: params[:job_application_id],
              contact_message_id: params[:contact_message_id],
              user_saved_job_posting_id: params[:user_saved_job_posting_id],
            }
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: TARGET_JOB_POSTING_AD_APPLY,
            params: {
              job_posting_id: params[:job_posting_id],
              user_id: params[:user_id],
              application_type: params[:application_type],
              job_application_id: params[:job_application_id],
              contact_message_id: params[:contact_message_id],
              user_saved_job_posting_id: params[:user_saved_job_posting_id],
            }
          }) unless Jets.env.development?
      else
        NotificationServiceJob.perform_now(
          :notify,
          {
            message_template_id: params[:template],
            params: params
          }) if Jets.env.development?
        NotificationServiceJob.perform_later(
          :notify,
          {
            message_template_id: params[:template],
            params: params
          }) unless Jets.env.development?
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
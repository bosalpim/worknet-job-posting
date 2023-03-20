class BizcallCallbacksController < ApplicationController
  def user_call_failure_alert
    event = { user_id: params[:user_id], job_posting_id: params[:job_posting_id] }
    rsp = UserCallFailureAlertJob.perform_now(:dig, event) if Jets.env.development?
    UserCallFailureAlertJob.perform_later(:dig, event) unless Jets.env.development?
    render json: Jets.env != 'production' ? rsp : { success: true }, status: :ok
  end

  def business_call_failure_alert
    event = { proposal_id: params[:proposal_id] }
    rsp = BusinessCallFailureAlertJob.perform_now(:dig, event) if Jets.env.development?
    BusinessCallFailureAlertJob.perform_later(:dig, event) unless Jets.env.development?
    render json: Jets.env != 'production' ? rsp : { success: true }, status: :ok
  end
end

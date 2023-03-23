class AppliesController < ApplicationController
  def new_notification
    event = { apply_id: params[:apply_id] }
    rsp = NewApplyJob.perform_now(:dig, event) if Jets.env.development?
    NewApplyJob.perform_later(:dig, event) unless Jets.env.development?
    render json: Jets.env != 'production' ? rsp : { success: true }, status: :ok
  end
end

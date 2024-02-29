class AppliesController < ApplicationController
  def new_notification
    event = { apply_id: params[:id] }
    rsp = NewApplyJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end
end

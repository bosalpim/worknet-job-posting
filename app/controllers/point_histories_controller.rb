class PointHistoriesController < ApplicationController
  def add_point_changed_active_user
    event = { user_id: params["user_id"] }
    rsp = PointHistoriesJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end
end

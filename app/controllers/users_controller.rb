class UsersController < ApplicationController
  def active_service_guide
    event = { user_id: params["user_id"] }
    ActiveUserServiceGuideJob.perform_later(:dig, event)
    render json: { success: true }, status: :ok
  end
end
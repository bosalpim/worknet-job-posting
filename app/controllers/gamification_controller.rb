class GamificationController < ApplicationController
  def missionComplete
    event = { user_id: params["user_id"] }
    rsp = GamificationMissionCompleteJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end
end

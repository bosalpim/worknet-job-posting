class GamificationMissionCompleteJob < ApplicationJob
  def dig
    service = GamificationMissionCompleteService.new(event[:user_id])
    service.send_mission_complete_message
  end
end

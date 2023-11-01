class ActiveUserServiceGuideJob < ApplicationJob
  def dig
    ActiveUserServiceGuideService.call(event[:user_id], event[:treatment_key])
  end
end
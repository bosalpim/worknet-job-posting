class ActiveUserServiceGuideJob < ApplicationJob
  def dig
    ActiveUserServiceGuideService.call(event[:user_id])
  end
end
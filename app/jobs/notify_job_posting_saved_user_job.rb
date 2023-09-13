class NotifyJobPostingSavedUserJob < ApplicationJob
  def dig
    NotifyJobPostingSavedUserService.call(event)
  end
end
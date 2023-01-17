class GetWorknetJobPostingJob < ApplicationJob
  rate "10 minutes" # every 10 hours
  def dig
    GetWorknetJobService.call
  end
end

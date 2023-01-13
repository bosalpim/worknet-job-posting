class GetWorknetJobPostingJob < ApplicationJob
  rate "10 minutes" # every 10 minutes
  def dig
    GetWorknetJobService.call
  end
end

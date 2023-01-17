class GetWorknetJobPostingJob < ApplicationJob
  rate "10 minutes" # every 10 hours
  def dig
    puts "done digging"
    GetWorknetJobService.call
  end
end

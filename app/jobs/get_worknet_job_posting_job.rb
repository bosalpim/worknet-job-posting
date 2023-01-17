class GetWorknetJobPostingJob < ApplicationJob
  rate "10 minutes" # every 10 hours
  def dig
    puts "================= Start Get Job Posting ================="
    GetWorknetJobService.call
    puts "================= Finish Get Job Posting ================="
  end
end

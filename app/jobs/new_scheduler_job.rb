class NewSchedulerJob < ApplicationJob

  cron "0 0 ? * * *"

  def test_job
    puts "test job"
  end

end
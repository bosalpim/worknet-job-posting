class SendNewsPaperJob < ApplicationJob
  cron "0 1 * * ? *"
  def send_to_actively
    SendNewsPaperService.new(User::job_search_statuses.dig(:actively)).call
  end

  cron "0 1 ? * MON,THU *"
  def send_to_commonly
    SendNewsPaperService.new(User::job_search_statuses.dig(:commonly)).call
  end

  cron "0 3 ? * 2#1 *"
  def send_to_off
    SendNewsPaperService.new(User::job_search_statuses.dig(:off)).call
  end

  cron "0 3 ? * 2#1,2#3 *"
  def send_to_working
    SendNewsPaperService.new(User::job_search_statuses.dig(:working)).call
  end
end

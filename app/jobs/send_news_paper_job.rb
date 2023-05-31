class SendNewsPaperJob < ApplicationJob
  cron "0 3 ? * 2#1 *"
  def send_to_off
    SendNewsPaperService.call(User::job_search_statuses.dig(:off))
  end

  cron "0 3 ? * 2#1 *"
  def send_to_working
    SendNewsPaperService.call(User::job_search_statuses.dig(:working))
  end

  cron "0 3 ? * 2#3 *"
  def send_to_working2
    SendNewsPaperService.call(User::job_search_statuses.dig(:working))
  end
end

class SendNewPaperJob < ApplicationJob
  cron "0 1 * * ? *"
  def send_to_actively
    SendNewsPaperService(User::job_search_statuses.dig(:actively))
  end

  cron "0 1 ? * MON,THU *"
  def send_to_commonly
    SendNewsPaperService(User::job_search_statuses.dig(:commonly))
  end

  cron "0 3 ? * 2#1 *"
  def send_to_off
    SendNewsPaperService(User::job_search_statuses.dig(:off))
  end

  cron "0 3 ? * 2#1,2#3 *"
  def send_to_working
    SendNewsPaperService(User::job_search_statuses.dig(:working))
  end
end

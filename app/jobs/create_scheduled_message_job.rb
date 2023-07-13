class CreateScheduledMessageJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "0 20 ? * SUN *"

  def create_news_paper_mon_message
    CreateNewsPaperActivelyCommonMessageService.call
  end

  cron "0 20 ? * WED *"

  def create_news_paper_thu_message
    CreateNewsPaperActivelyCommonMessageService.call
  end
end

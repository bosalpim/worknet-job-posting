class SendScheduledMessageJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"

  cron "2 1 ? * THU *"
  def send_news_paper_tuesday_message_0
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0)
  end

  cron "12 1 ? * THU *"
  def send_news_paper_tuesday_message_1
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.1)
  end

  cron "22 1 ? * THU *"
  def send_news_paper_tuesday_message_2
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.2)
  end

  cron "32 1 ? * THU *"
  def send_news_paper_tuesday_message_3
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.3)
  end

  cron "42 1 ? * THU *"
  def send_news_paper_tuesday_message_4
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.4)
  end

  cron "52 1 ? * THU *"
  def send_news_paper_tuesday_message_5
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.5)
  end

  cron "2 2 ? * THU *"
  def send_news_paper_tuesday_message_6
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.6)
  end

  cron "12 2 ? * THU *"
  def send_news_paper_tuesday_message_7
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.7)
  end

  cron "22 2 ? * THU *"
  def send_news_paper_tuesday_message_8
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.8)
  end

  cron "32 2 ? * THU *"
  def send_news_paper_tuesday_message_9
    SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.9)
  end

  # --------------------------------------------------------------------

  # cron "2 1 ? * MON *"
  # def send_news_paper_monday_message_0
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0)
  # end
  #
  # cron "12 1 ? * MON *"
  # def send_news_paper_monday_message_1
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.1)
  # end
  #
  # cron "22 1 ? * MON *"
  # def send_news_paper_monday_message_2
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.2)
  # end
  #
  # cron "32 1 ? * MON *"
  # def send_news_paper_monday_message_3
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.3)
  # end
  #
  # cron "42 1 ? * MON *"
  # def send_news_paper_monday_message_4
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.4)
  # end
  #
  # cron "52 1 ? * MON *"
  # def send_news_paper_monday_message_5
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.5)
  # end
  #
  # cron "2 2 ? * MON *"
  # def send_news_paper_monday_message_6
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.6)
  # end
  #
  # cron "12 2 ? * MON *"
  # def send_news_paper_monday_message_7
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.7)
  # end
  #
  # cron "22 2 ? * MON *"
  # def send_news_paper_monday_message_8
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.8)
  # end
  #
  # cron "32 2 ? * MON *"
  # def send_news_paper_monday_message_9
  #   SendCreatedScheduledMessageService.call(KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.9)
  # end
end

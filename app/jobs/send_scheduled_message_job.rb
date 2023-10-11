class SendScheduledMessageJob < ApplicationJob
  # 목요일 오전 10시 32분부터 10분 간격으로 10번 전송
  cron "32 1 ? * THU *"

  def send_news_paper_thursday_message_0
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0)
  end

  cron "42 1 ? * THU *"

  def send_news_paper_thursday_message_1
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.1)
  end

  cron "52 1 ? * THU *"

  def send_news_paper_thursday_message_2
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.2)
  end

  cron "2 2 ? * THU *"

  def send_news_paper_thursday_message_3
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.3)
  end

  cron "12 2 ? * THU *"

  def send_news_paper_thursday_message_4
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.4)
  end

  cron "22 2 ? * THU *"

  def send_news_paper_thursday_message_5
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.5)
  end

  cron "32 2 ? * THU *"

  def send_news_paper_thursday_message_6
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.6)
  end

  cron "42 2 ? * THU *"

  def send_news_paper_thursday_message_7
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.7)
  end

  cron "52 2 ? * THU *"

  def send_news_paper_thursday_message_8
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.8)
  end

  cron "2 3 ? * THU *"

  def send_news_paper_thursday_message_9
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.9)
  end

  # 월요일 오전 10시 32분부터 10분 간격으로 10번 전송
  cron "32 1 ? * MON *"

  def send_news_paper_monday_message_0
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0)
  end

  cron "42 1 ? * MON *"

  def send_news_paper_monday_message_1
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.1)
  end

  cron "52 1 ? * MON *"

  def send_news_paper_monday_message_2
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.2)
  end

  cron "2 2 ? * MON *"

  def send_news_paper_monday_message_3
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.3)
  end

  cron "12 2 ? * MON *"

  def send_news_paper_monday_message_4
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.4)
  end

  cron "22 2 ? * MON *"

  def send_news_paper_monday_message_5
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.5)
  end

  cron "32 2 ? * MON *"

  def send_news_paper_monday_message_6
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.6)
  end

  cron "42 2 ? * MON *"

  def send_news_paper_monday_message_7
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.7)
  end

  cron "52 2 ? * MON *"

  def send_news_paper_monday_message_8
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.8)
  end

  cron "2 3 ? * MON *"

  def send_news_paper_monday_message_9
    SendCreatedScheduledMessageService.call(MessageTemplate::NEWSPAPER_V2, KakaoNotificationResult::NEWS_PAPER, 0.1, 0.9)
  end
end

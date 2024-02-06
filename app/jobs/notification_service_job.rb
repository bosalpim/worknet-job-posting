class NotificationServiceJob < ApplicationJob
  def notify
    Jets.logger.info event
    process(event)
  end

  cron "0 4 ? * * *"

  def notify_saved_job_user_1day_ago
    process({ message_template_id: MessageTemplateName::CALL_SAVED_JOB_POSTING_V2 })
  end

  cron "0 7 ? * * *"

  def cbt_draft_until_3day
    process({ message_template_id: MessageTemplateName::CBT_DRAFT })
  end

  cron "0 7 ? * * *"

  def notify_draft_new_user
    process({ message_template_id: MessageTemplateName::CAREPARTNER_PRESENT })
  end

  cron "0 7 ? * 6 *"

  def notify_3month_draft_user
    process({ message_template_id: MessageTemplateName::ACCUMULATED_DRAFT })
  end

  cron "0 7 ? * 6 *"

  def cbt_expected_acquisition_user
    process({ message_template_id: MessageTemplateName::ACCUMULATED_PREPARATIVE })
  end

  private

  def process(event)
    begin
      # 발송 데이터 생성
      notification = Notification::FactoryService.create(event[:message_template_id], event[:params])
      notification.process
    rescue => e
      Jets.logger.info e.full_message
    end
  end
end
class NotificationServiceJob < ApplicationJob
  include AlimtalkMessage
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

  cron "0 0 ? * * *"

  def target_job_posting_performance
    process({ message_template_id: MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE })
  end


  cron "0 4 ? * * *"

  def target_job_posting_ads_after_posting_3days
    process( { message_template_id: MessageTemplates::TEMPLATES[MessageNames::TARGET_JOB_POSTING_AD_2] })
  end

  private

  def process(event)
    begin
      # 발송 데이터 생성
      Jets.logger.info event
      
      notification = Notification::FactoryService.create(event[:message_template_id], event[:params])
      notification.process
    rescue => e
      Jets.logger.info e.full_message
    end
  end
end
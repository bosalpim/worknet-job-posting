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

  cron "0 7 ? * MON-THU,SAT-SUN *"

  def cbt_draft_until_3day
    process({ message_template_id: MessageTemplates[MessageNames::CBT_DRAFT_CRM] })
  end

  cron "0 7 ? * MON-THU,SAT-SUN *"

  def notify_draft_new_user
    process({ message_template_id: MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM] })
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

  private

  def process(event)
    begin
      # 발송 데이터 생성
      Jets.logger.info event
      
      notification = Notification::FactoryService.create(event[:message_template_id], event[:params])
      notification.process
    rescue => e
      SlackWebhookService.call(:dev_alert, @fail_alert_message_payload) unless @fail_alert_message_payload.nil?
      Jets.logger.info e.full_message
    end
  end
end
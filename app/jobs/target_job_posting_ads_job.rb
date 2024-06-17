class TargetJobPostingAdsJob < ApplicationJob
  include AlimtalkMessage

  cron "0 4 ? * * *"
  def target_posting_ads_after_3days
    begin
      Jets.logger.info event

      notification = Notification::FactoryService.create(MessageTemplates::TEMPLATES[MessageNames::TARGET_JOB_POSTING_AD_2], nil)
      notification.process
    rescue => e
      Jets.logger.info e.full_message
    end

  end

end
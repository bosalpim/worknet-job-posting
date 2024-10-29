class PlustalkAdsJob < ApplicationJob
  include AlimtalkMessage

  cron "0 4 ? * * *"
  def plustalk_ads
    begin
      Jets.logger.info event

      notification = Notification::FactoryService.create(MessageTemplates::TEMPLATES[MessageNames::PLUSTALK_ADS], nil)
      notification.process
    rescue => e
      Jets.logger.info e.full_message
    end

  end

end
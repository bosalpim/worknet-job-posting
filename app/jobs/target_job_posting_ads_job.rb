class TargetJobPostingAdsJob < ApplicationJob
  include AlimtalkMessage

  cron "0 4 ? * * *"
  def target_posting_ads_after_3days
    JobSupportProject::SubmitRemindService.new(3, '안녕하세요 케어파트너입니다. 채용지원금 신청 서류 제출 일자가 지나 다시 연락드렸습니다.', 1).call
    # begin
    #   Jets.logger.info event
    #
    #   notification = Notification::FactoryService.create(MessageTemplates::TEMPLATES[MessageNames::TARGET_JOB_POSTING_AD_2], nil)
    #   notification.process
    # rescue => e
    #   Jets.logger.info e.full_message
    # end

  end

end
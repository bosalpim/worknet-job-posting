class ProposalNotificationExpiresAlertJob < ApplicationJob
  # (한국 시간) 매일 오전 9시에 전화면접 제안 알림 켜진 유저중 만료일이 1일 이하 남은 유저에게 발송
  cron "0 0 * * ? *"
  def alert_expires_proposal_notification
    ProposalNotificationExpiresService.call
  end
end

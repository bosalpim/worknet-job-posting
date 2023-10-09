class NotificationServiceJob < ApplicationJob
  BIZM_POST_PAY = "BIZM_POST_PAY"
  def notify
    # 발송 데이터 생성
    request_sources = Notification::CreateService.create(event[:template_id], event[:params])
    # 발송 (ps. 메세지 성공/실패에 따른 이벤트로깅은 재발송등 사후 처리의 편의성을 위해 Amplitude 로깅이 함께 수행됩니다.)
    process_result = Notification::SendService.send_messages(event[:template_id], request_sources)
    # 발송결과 DB 저장 (사후 처리 대상 구분되도록 DB 내역을 생성해야합니다.)
    Notification::ResultProcessService.process_result(event[:template_id], process_result)
  end

  cron "0 4 ? * * *"
  def notify_saved_job_user_1day_ago
    template_id = KakaoTemplate::CALL_SAVED_JOB_POSTING_V2
    # 발송 데이터 생성
    request_sources = Notification::CreateService.create(template_id, nil)
    # 발송 (ps. 메세지 성공/실패에 따른 이벤트로깅은 재발송등 사후 처리의 편의성을 위해 Amplitude 로깅이 함께 수행됩니다.)
    process_result = Notification::SendService.send_messages(template_id, request_sources)
    # 발송결과 DB 저장 (사후 처리 대상 구분되도록 DB 내역을 생성해야합니다.)
    Notification::ResultProcessService.process_result(template_id, process_result)
  end
end
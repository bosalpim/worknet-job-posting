# frozen_string_literal: true

class ProposalNotificationExpiresService
  def self.call
    new.call()
  end
  def process(event)
    # 발송 데이터 생성
    notification = Notification::FactoryService.create(event[:message_template_id], event[:params])
    # 발송 (ps. 메세지 성공/실패에 따른 이벤트로깅은 재발송등 사후 처리의 편의성을 위해 Amplitude 로깅이 함께 수행됩니다.)
    notification.notify
    # 발송결과 DB 저장 (사후 처리 대상 구분되도록 DB 내역을 생성해야합니다.)
    notification.save_result
  end

  def call
    process({message_template_id: MessageTemplateName::PROPOSAL_NOTIFICATION_EXPIRES, params: {}})
  end
end

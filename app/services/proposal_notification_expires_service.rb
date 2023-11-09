# frozen_string_literal: true

class ProposalNotificationExpiresService
  def self.call
    new.call()
  end

  def getTargetUsers
    users = User.receive_proposal_notifications
    # 현재 시간으로부터 하루 이내에 만료되는 유저 조회
    users = users.where('expiresAt > ? AND expiresAt <= ?', Time.current, 1.day.from_now)
    users
  end

  def call
    users = getTargetUsers
    users
  end
end

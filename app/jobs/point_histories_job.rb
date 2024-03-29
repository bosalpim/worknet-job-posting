class PointHistoriesJob < ApplicationJob
  CHUSEOK_THANKS = 'chuseok_thanks'
  TARGET_INVITE_TYPE = ['point_invite_friend' , 'chuseok_invite', CHUSEOK_THANKS]
  def dig
    update_point_invite_history(event)
  end

  private
  def update_point_invite_history(event)
    user = User.find_by(id: event[:user_id])
    user_id = User.find_by(id: event[:user_id]).id
    histories = InvitedHistory.where(user_id: user_id).order(created_at: 'desc')
    target_history = nil
    is_chuseok_thanks = false
    target_code = nil

    if histories.length > 0
      histories.find_each do |history|
        target_code = InviteCode.find_by(id: history.invite_code_id)
        if TARGET_INVITE_TYPE.include?(target_code.invite_type)
          target_history = history
          is_chuseok_thanks = target_code.invite_type == CHUSEOK_THANKS
        end
      end
    end

    begin
      ActiveRecord::Base.transaction do
        if target_history.nil? || histories.length == 0
          # 초대 코드가 없으면 가입한 사람에게만 축하포인트 적립
          item = PointItem.find_by(item_type: 'welcome')
          PointHistory.create!(point_item_id: item.id, user_id: user.id)
        else
          # 초대 코드가 있으면 양측에 친구초대 포인트 적립
          target_history.update!(condition_fulfilled: true)
          item = PointItem.find_by(item_type: 'invite')
          PointHistory.create!(point_item_id: item.id, user_id: target_code.user_id)
          PointHistory.create!(point_item_id: item.id, user_id: user_id)
          # 감사카드 유저면 박카스 선물
          if is_chuseok_thanks
            GiftVoucherReward.create!(user_id: user_id, reward_type: CHUSEOK_THANKS)
          end
        end
      end
    rescue
      if target_history.nil?
        Jets.logger.info "user_id : #{user_id} 관련 가입 포인트 누적 실패 대처 X"
      else
        Jets.logger.info "history_id : #{target_history.id} 관련 초대 포인트 누적 실패 대처 필요"
      end
    end
  end
end

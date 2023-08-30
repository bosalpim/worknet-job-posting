class GiftVoucherReward < ApplicationRecord
  belongs_to :user

  enum reward_type: {
    invite: 'invite',
    yobosaday_bacchus: "yobosaday_bacchus",
    chuseok_thanks: PointHistoriesJob::CHSEOK_THANKS
  }
end

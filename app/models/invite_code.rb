class InviteCode < ApplicationRecord
  belongs_to :business, optional: true
  belongs_to :user, optional: true

  has_many :invited_histories
end

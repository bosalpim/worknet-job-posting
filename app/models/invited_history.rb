class InvitedHistory < ApplicationRecord
  belongs_to :invite_code
  belongs_to :user
end
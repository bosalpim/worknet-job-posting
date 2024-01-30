class Notification < ApplicationRecord
  PROPOSAL_ACCEPTED = "proposal_accepted".freeze
  PROPOSAL_REJECTED = "proposal_rejected".freeze
  PROPOSAL_READ  = "proposal_read".freeze
  NEW_APPLY  = "new_apply".freeze

  belongs_to :notifiable, polymorphic: true
end

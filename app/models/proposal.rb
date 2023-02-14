class Proposal < ApplicationRecord
  belongs_to :business
  belongs_to :user

  validates :job_posting_id, presence: true
  validates :client_id, presence: true
  validates :use_type, presence: true

  enum use_type: {
    free: 'free',
    paid: 'paid'
  }
end

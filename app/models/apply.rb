class Apply < ApplicationRecord
  belongs_to :business
  belongs_to :user

  validates :job_posting_id, presence: true
  validates :status, presence: true
  validates :is_open_vn, inclusion: { in: [true, false] }

  # waiting, checked, called, closed
  enum status: {
    waiting: 'waiting',
    opened: 'opened',
    called: 'called',
    closed: 'closed',
  }
end

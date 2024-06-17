class Business < ApplicationRecord
  include StringNumber

  set_string_number_fields :phone_number, :business_number

  validates :proposal_usable_count, numericality: { greater_than_or_equal_to: 0 }

  has_many :job_postings
  has_many :business_clients
  has_many :clients, through: :business_clients
  has_many :proposals, dependent: :destroy
  has_many :proposed_users, through: :proposals, source: :user
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_one :business_registration, dependent: :destroy

  validates :business_number, uniqueness: { allow_blank: true }
end

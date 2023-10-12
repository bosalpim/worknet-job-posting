class MessageTemplate < ApplicationRecord
  validates :target_medium, inclusion: { in: %w(kakao_arlimtalk app_push) }
end

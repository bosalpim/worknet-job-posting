class Game < ApplicationRecord
  # 관계 정의
  has_many :game_user_scores

end

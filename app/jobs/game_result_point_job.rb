class GameResultPointJob < ApplicationJob
  include NotificationType

  cron "0 15 * * ? *"
  def give_game_ranker_point
    GameResultRankerPoint.new
  end
end
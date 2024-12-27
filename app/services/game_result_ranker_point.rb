class GameResultRankerPoint
  def initialize
    offer_point
  end

  def get_ranker
    # 오늘 날짜 (UTC+9 기준) 계산
    today_date = Time.now.to_date

    # `games` 테이블에서 `name`이 'yoyang_run'인 데이터의 ID를 가져옴
    game = Game.find_by(name: 'yoyang_run')

    return [] unless game

    # `game_user_scores`에서 오늘 날짜 기준으로 `score`가 가장 높은 상위 3개를 가져옴
    GameUserScore
      .where(game_id: game.id, date: today_date)
      .order(score: :desc)
      .limit(3)
  end

  def offer_point
    rankers = get_ranker
    return if rankers.empty?

    # Point item 타입별 ID를 가져옴
    point_items = PointItem.where(item_type: ['game_1st', 'game_2nd', 'game_3rd']).index_by(&:item_type)

    rankers.each_with_index do |ranker, index|
      item_type = case index
                  when 0 then 'game_1st'
                  when 1 then 'game_2nd'
                  when 2 then 'game_3rd'
                  end

      # 해당하는 PointItem이 없으면 건너뜀
      next unless point_items[item_type]

      # `point_histories`에 데이터 생성
      PointHistory.create(
        user_id: ranker.user_id,
        point_item_id: point_items[item_type].id,
        created_at: Time.now,
        updated_at: Time.now
      )
    end
  end
end

module DayHelper
  include TranslationHelper
  ALL_DAYS = %w[monday tuesday wednesday thursday friday saturday sunday]

  def count_days(days)
    days.count
  end

  # 배열에 없는 요일들을 찾아 "/"로 이어붙인 문자열을 반환하는 함수
  def missing_days(days)
    ALL_DAYS - days
  end

  def trim_days_to_text(days)
    translate_type()
  end
end
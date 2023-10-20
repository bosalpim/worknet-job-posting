module RatioChopper
  def self.chop_list(target_list, ratio)
    # 비율에 따른 원소 개수 계산
    count = (target_list.length * ratio * 0.01).round
    # 원소 추출
    target_list.sample(count)
  end

end
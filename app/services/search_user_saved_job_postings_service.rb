class SearchUserSavedJobPostingsService
  def self.call(days)
    new(days).call
  end

  def initialize(days)
    @days = days
  end

  def call
    today = Time.now
    # 해당하는 날짜만큼 계산
    yesterday = today - @days.day

    # 00:00:00부터 23:59:59까지의 범위를 계산
    start_of_day = yesterday.beginning_of_day
    end_of_day = yesterday.end_of_day

    # 범위에 해당하는 데이터 쿼리
    UserSavedJobPosting.where(created_at: start_of_day..end_of_day)
  end
end
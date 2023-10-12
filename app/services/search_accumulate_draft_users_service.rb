class SearchAccumulateDraftUsersService
  def self.call(ago_months)
    new(ago_months).call
  end

  def initialize(ago_months)
    @ago_months = ago_months
  end

  def call
    today = Time.now
    # 해당하는 날짜만큼 계산
    date_months_ago = Date.today << @ago_months
    first_day_months_ago = Date.new(date_months_ago.year, date_months_ago.month, 1)

    # 2달 전 1일부터 ~ 오늘까지
    start_of_day = first_day_months_ago
    end_of_day = today

    # 범위에 해당하는 데이터 쿼리
    User.where(created_at: start_of_day..end_of_day, status: 'draft')
  end
end
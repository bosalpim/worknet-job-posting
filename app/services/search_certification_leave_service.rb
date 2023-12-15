class SearchCertificationLeaveService
  def self.call(ago_days)
    new(ago_days).call
  end

  def initialize(ago_days)
    @ago_days = ago_days
  end

  def call
    today = Time.now
    # 해당하는 날짜만큼 계산
    yesterday = today - 1.day
    target_day = today - @ago_days.day

    # 00:00:00부터 23:59:59까지의 범위를 계산
    start_of_day = target_day.beginning_of_day
    end_of_day = yesterday.end_of_day

    # 범위에 해당하는 데이터 쿼리
    User.where(created_at: start_of_day..end_of_day, draft_status: 'certificationEnroll')
  end
end
class SearchPreparativeCbtUsersService
  def self.call
    new.call
  end

  def initialize
  end

  def call
    # 현재 날짜를 기준으로 필요한 값들을 계산
    now = Date.today
    last_month = now << 1
    month_before_last = now << 2
    ninety_days_ago = now - 31 # Todo 점전적 배포 예정 31 -> 61 -> 91
    one_days_ago = now - 1

    # 연도.월과 연도.월.일 형식으로 변환
    last_month_str = last_month.strftime('%y/%m')
    month_before_last_str = month_before_last.strftime('%y/%m')

    # 쿼리
    # %y.%m으로 저장된 경우는 이전달, 혹은 이전전달
    # %y.%m.%d로 저장된 경우는 91일전부터 1일전까지
    # 예: 23년 10월 13일 기준 23.08, 23.09, 23.07.14~23.10.12
    # Todo 점진적 배포. x -> 이전 달 -> 이전전달

    # 1단계 x 달 쿼리
    users = User.where(
      'expected_acquisition >= ? AND expected_acquisition <= ? AND (LENGTH(expected_acquisition) = 8 OR LENGTH(expected_acquisition) = 7)',
      ninety_days_ago.strftime('%y/%m/%d'), one_days_ago.strftime('%y/%m/%d')
    )

    # 2단계 이전 달 쿼리
    # users = User.where(
    #   '(expected_acquisition IN (?) AND LENGTH(expected_acquisition) = 5) OR (expected_acquisition >= ? AND expected_acquisition <= ? AND (LENGTH(expected_acquisition) = 8 OR LENGTH(expected_acquisition) = 7))',
    #   last_month_str,
    #   ninety_days_ago.strftime('%y/%m/%d'), one_days_ago.strftime('%y/%m/%d')
    # )

    # 3단계 이전전달 쿼리
    # users = User.where(
    #   '(expected_acquisition IN (?, ?) AND LENGTH(expected_acquisition) = 5) OR (expected_acquisition >= ? AND expected_acquisition <= ? AND (LENGTH(expected_acquisition) = 8 OR LENGTH(expected_acquisition) = 7))',
    #   month_before_last_str, last_month_str,
    #   ninety_days_ago.strftime('%y/%m/%d'), one_days_ago.strftime('%y/%m/%d')
    # )
    users.where(has_certification: false, status: 'active')

  end
end
class GetWorknetJobPostingJob < ApplicationJob

  # 한국시간 기준 매일 오전 8시부터 19시까지 10분에 한번씩 돌아감
  cron "0/10 0,1,2,3,4,5,6,7,8,9,10,23 * * ? *"
  def dig
    GetWorknetJobService.call
  end
end

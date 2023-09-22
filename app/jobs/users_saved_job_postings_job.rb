class UsersSavedJobPostingsJob < ApplicationJob
  # cron "0 4 ? * * *"
  # def notify_saved_job_user_1day_ago
  #   # 하루전 (00:00 - 24:00) 시점의 관심일자리 리스트 긁어오기
  #   saved_job_1day_ago = SearchUserSavedJobPostingsService.call(1)
  #   unless saved_job_1day_ago.count == 0
  #   #   메세지 만들어서 발송!
  #   NotifySavedJobUserService.call(saved_job_1day_ago)
  #   end
  # end
end
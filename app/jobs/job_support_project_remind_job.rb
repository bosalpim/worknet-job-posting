class JobSupportProjectRemindJob < ApplicationJob

  cron "0 0 ? * * *"
  def first_submit_remind
    JobSupportProject::SubmitRemindService.new(2, '채용 지원금 서류 제출 기한이 오늘까지 입니다. 확인 후 제출해주세요.', 0).call
  end

  cron "0 4 ? * * *"
  def second_submit_remind
    JobSupportProject::SubmitRemindService.new(3, '채용지원금 신청 서류 제출 일자가 지나 다시 연락드렸습니다.', 0).call
  end

end
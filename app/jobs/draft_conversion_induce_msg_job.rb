class DraftConversionInduceMsgJob < ApplicationJob
  cron "0 7 ? * * *"
  def first_day_except_address
    DraftConversionMessageService.call(KakaoTemplate::HIGH_SALARY_JOB)
  end

  cron "0 7 ? * * *"
  def first_day_only_address
    DraftConversionMessageService.call(KakaoTemplate::ENTER_LOCATION)
  end

  cron "0 7 ? * * *"
  def second_day_except_address
    DraftConversionMessageService.call(KakaoTemplate::WELL_FITTED_JOB)
  end

  cron "0 7 ? * * *"
  def check_certification
    DraftConversionMessageService.call(KakaoTemplate::CERTIFICATION_UPDATE)
  end
end
class DraftConversionInduceMsgJob < ApplicationJob
  cron "0 7 ? * * *"
  def first_day_except_address
    DraftConversionMessageService.call(MessageTemplateName::HIGH_SALARY_JOB)
  end

  cron "0 7 ? * * *"
  def first_day_only_address
    DraftConversionMessageService.call(MessageTemplateName::ENTER_LOCATION)
  end

  cron "0 7 ? * * *"
  def second_day_except_address
    DraftConversionMessageService.call(MessageTemplateName::WELL_FITTED_JOB)
  end

  cron "0 7 ? * * *"
  def check_certification
    DraftConversionMessageService.call(MessageTemplateName::CERTIFICATION_UPDATE)
  end
end
class DraftConversionInduceMsgJob < ApplicationJob
  include AlimtalkMessage

  cron "0 7 ? * MON-THU,SAT-SUN *"
  def first_day_except_address
    DraftConversionMessageService.call(MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM])
  end

  cron "0 7 ? * MON-THU,SAT-SUN *"
  def first_day_only_address
    DraftConversionMessageService.call(MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM])
  end

  cron "0 7 ? * MON-THU,SAT-SUN *"
  def second_day_except_address
    DraftConversionMessageService.call(MessageTemplates[MessageNames::TWO_DAY_CAREPARTNER_DRAFT_CRM])
  end

  cron "0 7 ? * MON-THU,SAT-SUN *"
  def check_certification
    DraftConversionMessageService.call(MessageTemplateName::CERTIFICATION_UPDATE)
  end
end
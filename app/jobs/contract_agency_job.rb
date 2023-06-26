class ContractAgencyJob < ApplicationJob
  cron "0 5 ? * MON *"
  # def send_contract_agency1
  #   ContractAgencyService.call(7)
  # end

  cron "0 5 ? * TUE *"
  def send_contract_agency2
    ContractAgencyService.call(8)
  end

  cron "0 5 ? * FRI *"
  def send_contract_agency3
    ContractAgencyService.call(3)
  end
end

class ContractAgencyJob < ApplicationJob
  cron "0 5 ? * TUE *"
  def send_contract_agency2
    ContractAgencyServiceEdit2.call(8)
  end

  cron "0 5 ? * FRI *"
  def send_contract_agency3
    ContractAgencyServiceEdit2.call(3)
  end
end

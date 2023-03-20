class BusinessCallFailureAlertJob < ApplicationJob
  def dig
    proposal = Proposal.find(event[:proposal_id])
    BusinessCallFailureAlertService.call(proposal)
  end
end

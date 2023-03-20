class BusinessCallFailureAlertJob < ApplicationJob
  def dig
    proposal = Proposal.find(event[:proposal_id])
    UserCallFailureAlertService.call(proposal)
  end
end

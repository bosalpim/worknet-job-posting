class NewProposalJob < ApplicationJob
  def dig
    new_proposal_service = NewProposalService.new(event[:proposal_id])
    new_proposal_service.call
  end
end

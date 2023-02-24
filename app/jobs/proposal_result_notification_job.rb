class ProposalResultNotificationJob < ApplicationJob
  def accepted
    proposal_result_notificaiton_service = ProposalResultNotificationService.new(event[:proposal_id])
    proposal_result_notificaiton_service.accepted_call
  end

  def rejected
    proposal_result_notificaiton_service = ProposalResultNotificationService.new(event[:proposal_id])
    proposal_result_notificaiton_service.rejected_call
  end
end

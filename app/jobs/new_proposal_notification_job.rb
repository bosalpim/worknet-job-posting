class NewProposalNotificationJob < ApplicationJob
  def perform(proposal_params)
    service = NewProposalNotificationService.new(
      proposal_params["current_client_id"],
      proposal_params["target_user_id"],
      proposal_params["job_posting_id"],
      proposal_params["proposal_id"]
    )
    service.call
  end
end

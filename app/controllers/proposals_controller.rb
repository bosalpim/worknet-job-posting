class ProposalsController < ApplicationController
  def create
    NewProposalNotificationJob.perform_now(proposal_params) if Jets.env.development?
    NewProposalNotificationJob.perform_later(proposal_params) unless Jets.env.development?
    render json: {
      success: true
    }, status: :ok
  end

  private

  def proposal_params
    params.require(:proposal).permit(:current_client_id, :target_user_id, :job_posting_id, :proposal_id)
  end
end

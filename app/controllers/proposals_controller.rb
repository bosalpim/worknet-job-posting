class ProposalsController < ApplicationController
  def new_notification
    event = { proposal_id: params["proposal_id"] }
    rsp = NewProposalJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end
end

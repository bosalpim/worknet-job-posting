class ProposalsController < ApplicationController
  def new_notification
    event = { proposal_id: params["proposal_id"] }
    rsp = NewProposalJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end

  def accepted
    event = { proposal_id: params["proposal_id"] }
    rsp = ProposalResultNotificationJob.perform_now(:accepted, event)
    render json: rsp, status: :ok
  end

  def rejected
    event = { proposal_id: params["proposal_id"] }
    rsp = ProposalResultNotificationJob.perform_now(:rejected, event)
    render json: rsp, status: :ok
  end
end

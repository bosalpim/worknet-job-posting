class ProposalsController < ApplicationController
  def new_notification
    event = { proposal_id: params["proposal_id"] }
    rsp = NewProposalJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end

  def call_interview_notification
    rsp = ProposalNotificationService.new(params).call
    render json: rsp, status: :ok
  end

  def call_interview_accepted
    rsp = CallInterviewAcceptedService.new(params).call
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

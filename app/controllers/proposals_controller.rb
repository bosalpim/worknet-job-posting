class ProposalsController < ApplicationController
  def new_notification
    event = { proposal_id: params["proposal_id"] }
    rsp = NewProposalJob.perform_now(:dig, event)
    render json: rsp, status: :ok
  end

  def new_v2
    rsp = Proposal::NewService.new(params).call
    render json: rsp, status: :ok
  end

  def accepted_v2
    notification = Notification::FactoryService.create(MessageTemplateName::CALL_INTERVIEW_ACCEPTED, params)
    notification.notify
    notification.save_result

    render json: {
      success: true
    }, status: :ok
  end

  def accepted
    event = { proposal_id: params["proposal_id"] }

    notification = Notification::FactoryService.create(MessageTemplateName::CALL_INTERVIEW_ACCEPTED, event)
    notification.notify
    notification.save_result

    render json: {
      success: true
    }, status: :ok
  end

  def rejected
    event = { proposal_id: params["proposal_id"] }
    rsp = ProposalResultNotificationJob.perform_now(:rejected, event)
    render json: rsp, status: :ok
  end
end

class UsersController < ApplicationController
  def active_service_guide
    event = { user_id: params["user_id"] }
    ActiveUserServiceGuideJob.perform_later(:dig, event)
    render json: { success: true }, status: :ok
  end

  def receive_roulette_ticket
    event = { user_id: params["user_id"] }
    NotifyReceiveRouletteTicketsJob.perform_later(:dig, event)
    render json: { success: true }, status: :ok
  end

  def notify_comment
    NotifyCommentService.call notify_comment_params

    render json: {
      success: true
    }, status: :ok
  end

  def notify_comment_params
    params.permit(:user_id, :phone, :post_title, :post_id, :public_id)
  end
end
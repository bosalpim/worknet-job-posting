# frozen_string_literal: true

class NotificationController < ApplicationController
  def ask_active
    Notification::AskActiveService.new(ask_active_params).call
  end

  def ask_active_params
    params.permit(:user_public_id, :business_name, :user_name, :job_posting_public_id, :job_posting_title)
  end

end

# frozen_string_literal: true

class NotificationController < ApplicationController
  def ask_active
    Notification::AskActiveService.new(ask_active_params).call
  end

  def ask_active_params
    params.permit(
      :url,
      :user_public_id,
      :user_name,
      :user_phone_number,
      :business_name,
      :job_posting_public_id,
      :job_posting_title)
  end
end
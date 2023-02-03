class JobPostingsController < ApplicationController
  include Translation
  include JobPostingsHelper

  def create
    GetWorknetJobService.call
  end

  def new_notification
    NewJobNotificationJob.perform_later(params[:job_posting_id])
    render json: {
      success: true
    }, status: :ok
  end
end

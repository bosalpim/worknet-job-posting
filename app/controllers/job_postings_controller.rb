class JobPostingsController < ApplicationController
  include Translation
  include JobPostingsHelper

  def create
    GetWorknetJobService.call
  end

  def new_notification
    event = { job_posting_id: params["job_posting_id"] }
    NewJobNotificationJob.perform_now(:call, event) # if Jets.env.development?
    # NewJobNotificationJob.perform_later(:call, event) unless Jets.env.development?
    render json: {
      success: true
    }, status: :ok
  end
end

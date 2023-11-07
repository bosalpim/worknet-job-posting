# frozen_string_literal: true

class JobApplicationsController < ApplicationController
  def new_application
    JobApplication::NewService.new(
      job_application_public_id: params[:job_application_id]
    ).call

    render json: { success: true }
  end
end

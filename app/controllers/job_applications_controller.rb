# frozen_string_literal: true

class JobApplicationsController < ApplicationController
  def new_application
    JobApplication::NewService.new(
      job_application_public_id: params[:id]
    ).call

    render json: { success: true }
  end
end

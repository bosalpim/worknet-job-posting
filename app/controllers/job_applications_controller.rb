# frozen_string_literal: true

class JobApplicationsController < ApplicationController
  def new_application
    notification = Notification::FactoryService.create(
      MessageTemplateName::JOB_APPLICATION,
      params
    )
    notification.notify
    notification.save_result

    render json: { success: true }
  end
end

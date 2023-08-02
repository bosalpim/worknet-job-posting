class CareerCertificationsController < ApplicationController
  def notify
    NotifyCareerCertificationService.call notify_params

    render json: {
      success: true
    }, status: :ok
  end

  def notify_params
    params.permit(:phone, :link, :center_name, :job_posting_title)
  end

end

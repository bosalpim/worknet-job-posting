class CareerCertificationsController < ApplicationController
  def notify
    NotifyCareerCertificationService.call notify_params

    render json: {
      success: true
    }, status: :ok
  end

  def notify_v2
    NotifyCareerCertificationServiceV2.call notify_v2_params

    render status: :ok,
           json: {
             success: true
           }
  end

  def notify_params
    params.permit(:phone, :link, :center_name, :job_posting_title)
  end

  def notify_v2_params
    params.permit(:phone, :link, :center_name, :job_posting_title, :user_id)
  end

end

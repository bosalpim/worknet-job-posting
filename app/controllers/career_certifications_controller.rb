class CareerCertificationsController < ApplicationController
  def notify
    NotifyCareerCertificationService.call notify_params

    render json: {
      success: true
    }, status: :ok
  end

  def confirm
    notification = Notification::FactoryService.create(MessageTemplateName::CONFIRM_CAREER_CERTIFICATION, params);
    notification.notify
    notification.save_result

    render json: {
      success: true
    }, status: :ok
  end

  def notify_params
    params.permit(:phone, :link, :center_name, :job_posting_title, :job_posting_public_id, :user_public_id)
  end
end

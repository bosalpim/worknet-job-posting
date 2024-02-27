class NoneLtcController < ApplicationController
  def new_none_ltc_request
    notification = Notification::FactoryService.create(MessageTemplateName::NONE_LTC_REQUEST, params);

    notification.notify
    notification.save_result

    render json: { success: true }
  end
end

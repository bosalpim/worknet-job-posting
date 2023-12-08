# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  def new_contact_message
    notification = Notification::FactoryService.create(MessageTemplateName::CONTACT_MESSAGE, params);

    notification.notify
    notification.save_result

    render json: { success: true }
  end
end

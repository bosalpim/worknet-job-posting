# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  def new_contact_message
    ContactMessage::CreateContactMessageService.new(
      contact_message_public_id: params[:contact_message_id]
    ).call

    render json: { success: true }
  end
end

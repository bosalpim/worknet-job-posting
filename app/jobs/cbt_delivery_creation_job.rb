# frozen_string_literal: true

class CbtDeliveryCreationJob < ApplicationJob


  cron "0 0 * * SUN *"
  def cbt_delivery_creation
    CbtDeliveryCreationService.call
  end


end

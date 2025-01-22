# frozen_string_literal: true

class CbtDeliveryCreationJob < ApplicationJob


  cron "0 0 * * SUN *"
  def cbt_delivery_creation
    if Jets.env.production?
      CbtDeliveryCreationService.call
    end
  end


end

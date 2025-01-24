# frozen_string_literal: true

class CbtDeliveryCreationJob < ApplicationJob


  cron "50 2 * * FRI *"
  def cbt_delivery_creation
    CbtDeliveryCreationService.call
  end


end

# frozen_string_literal: true

class CbtDeliveryCreationJob < ApplicationJob


  cron "20 8 * * WED *"
  def cbt_delivery_creation
    CbtDeliveryCreationService.call
  end


end

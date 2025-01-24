# frozen_string_literal: true

class CbtDeliveryCreationJob < ApplicationJob
  include AlimtalkMessage

  cron "10 0 ? * SUN *"
  def create_cbt_delivery
    CbtDeliveryCreationService.call
  end


end

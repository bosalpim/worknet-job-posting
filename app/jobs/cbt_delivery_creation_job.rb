# frozen_string_literal: true

class CbtDeliveryCreationJob < ApplicationJob
  include AlimtalkMessage

  cron "10 4 * * FRI *"
  def create_cbt_delivery
    CbtDeliveryCreationService.call
  end


end

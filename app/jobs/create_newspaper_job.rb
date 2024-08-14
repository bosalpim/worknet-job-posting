# frozen_string_literal: true

class CreateNewspaperJob < ApplicationJob
  cron "0 20 ? * SUN *"

  def create_monday_newspaper
    if Jets.env.production?
      Newspaper::PrepareService.new(
        date: DateTime.now,
      ).call
    elsif Jets.env.staging?
      Newspaper::PrepareService.new(
        date: DateTime.now,
        batch: 2
      ).call
    end
  end

  cron "0 20 ? * TUE *"

  def create_tuesday_newspaper
    if Jets.env.production?
      Newspaper::PrepareService.new(
        date: DateTime.now,
        ).call
    elsif Jets.env.staging?
      Newspaper::PrepareService.new(
        date: DateTime.now,
        batch: 2
      ).call
    end
  end

  cron "0 20 ? * WED *"

  def create_thursday_newspaper
    if Jets.env.production?
      Newspaper::PrepareService.new(
        date: DateTime.now,
      ).call
    elsif Jets.env.staging?
      Newspaper::PrepareService.new(
        date: DateTime.now,
        batch: 2
      )
    end
  end
end

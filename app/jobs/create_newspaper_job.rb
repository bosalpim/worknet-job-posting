# frozen_string_literal: true

class CreateNewspaperJob < ApplicationJob
  cron "2 9 ? * SUN *"

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

  cron "2 9 ? * WED *"

  def create_thursday_newspaper
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

  cron "2 9 ? * MON,TUE,THU *"

  def create_allday_newspaper
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
end

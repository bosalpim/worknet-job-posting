# frozen_string_literal: true

class CreateNewspaperJob < ApplicationJob
  def initialize(event, context, meth)
    super
  end

  cron "0 20 ? * SUN *"

  def create_monday_newspaper
    Newspaper::PrepareService.new(
      DateTime.now
    ).call
  end

  cron "05 7 ? * WED *"

  def create_thursday_newspaper
    Newspaper::PrepareService.new(
      DateTime.now
    ).call
  end
end

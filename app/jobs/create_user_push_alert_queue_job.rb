# frozen_string_literal: true

class CreateUserPushAlertQueueJob < ApplicationJob
  cron "0 20 ? * SUN *"

  def create_monday_newspaper

    if Jets.env.production?
      UserPushAlert::YoyangRunService.new(
        date: DateTime.now,
        ).prepare
    elsif Jets.env.staging?
      UserPushAlert::YoyangRunService.new(
        date: DateTime.now,
        batch: 2
      ).prepare
    end
  end
end

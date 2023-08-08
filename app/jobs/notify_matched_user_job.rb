# frozen_string_literal: true

class NotifyMatchedUserJob < ApplicationJob

  def process
    NotifyMatchedUserService.call(event)
  end
end

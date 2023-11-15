class NotifyReceiveRouletteTicketsJob < ApplicationJob
  def dig
    NotifyReceiveRouletteTicketsService.call(event[:user_id])
  end
end
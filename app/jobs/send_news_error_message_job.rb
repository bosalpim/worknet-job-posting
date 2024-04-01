class SendNewsErrorMessageJob < ApplicationJob
  def dig
    SendNewsErrorSlackMessageService.call
  end
end

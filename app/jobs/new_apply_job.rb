class NewApplyJob < ApplicationJob

  def dig
    apply = Apply.find(event[:apply_id])
    NewApplyService.call(apply)
  end
end

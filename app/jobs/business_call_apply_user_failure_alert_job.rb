class BusinessCallApplyUserFailureAlertJob < ApplicationJob
  def dig
    apply = Apply.find(event[:apply_id])
    BusinessCallApplyUserFailureAlertService.call(apply)
  end
end

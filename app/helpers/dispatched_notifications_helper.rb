module DispatchedNotificationsHelper
  def create_dispatched_notification_params(template_name, relate_type, relate_type_instance_id, receiver_type, receiver_id, target)
    "&template_name=#{template_name}" + "&notification_relate_type=#{relate_type}" + "&notification_relate_type_instance_id=#{relate_type_instance_id}" + "&receiver_type=#{receiver_type}" + "&receiver_id=#{receiver_id}" + "&confirmed=#{target}"
  end
end
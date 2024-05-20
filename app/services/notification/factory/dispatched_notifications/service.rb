class Notification::Factory::DispatchedNotifications::Service
  def self.call(template_name, relate_instance_type, relate_instance, receiver_type)
    new(template_name, relate_instance_type, relate_instance, receiver_type)
  end
  def initialize(template_name, relate_instance_type, relate_instance_id, receiver_type)
    @template_name = template_name
    @relate_instance_type = relate_instance_type
    @relate_instance_id = relate_instance_id
    @receiver_type = receiver_type
    @send_results = nil
    value_check
  end

  def set_dispatced_notifications(results)
      @send_results = results
      save_dispatced_notifications
  end

  private
  def save_dispatced_notifications
    @send_results.each do |result|
      begin
        next if result[:status] != 'success'
        target_public_id = result[:target_public_id]
        receiver_id = find_receiver_id(target_public_id)
        DispatchedNotification.create({
                                        message_template_name: @template_name,
                                        notification_relate_instance_types_id: NotificationRelateInstanceType.find_by(type_name: @relate_instance_type).id,
                                        notification_relate_instance_id: @relate_instance_id,
                                        receiver_type: @receiver_type,
                                        receiver_id: receiver_id
                                      })
      rescue => e
        Jets.logger.info "SET DISPATCHED ERROR : #{e.message}, template: #{@template_name}, instance_type: #{@relate_instance_type}, instance: #{@relate_instance_id}"
      end
    end
  end

  def find_receiver_id(target_public_id)
    if @receiver_type == 'yobosa'
      return User.find_by(public_id: target_public_id).id
    end

    if @receiver_type == 'client'
      return Client.find_by(public_id: target_public_id).id
    end
  end

  def value_check
    Jets.logger.info "메세지 생성에 사용되는 instance 항목에 포함된 대상만 전달해주세요." unless NotificationRelateInstanceType.all.pluck(:type_name).include? @relate_instance_type
    Jets.logger.info "메세지 생성에 사용되는 instance의 id를 보유한 형태로 전달해주세요." if @relate_instance_id == nil
  end
end
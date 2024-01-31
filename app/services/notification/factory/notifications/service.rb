class Notification::Factory::Notifications::Service
  def self.call(template_name, title, content, link, receiver_type)
    new(template_name, title, content, link, receiver_type)
  end

  def initialize(template_name, title, content, link, receiver_type)
    @template_name = template_name
    @title = title
    @content = content
    @link = link
    @receiver_type = receiver_type
  end

  def set_notifications(target_list)

    target_list.each do |public_id|
        begin
        receiver = find_receiver(public_id)
        receiver.notifications.create!({
                                         title: @title,
                                         content: @content,
                                         link: @link,
                                         notification_type: @template_name
                                       })
        rescue => e
          Jets.logger.info "SET NOTIFICATION ERROR : #{e.message}, template: #{@template_name}, receiver_type: #{@receiver_type}, receiver_id: #{public_id}"
        end
      end
  end

  private
  def find_receiver(target_public_id)
    if @receiver_type == 'yobosa'
      return User.find_by(public_id: target_public_id)
    end

    if @receiver_type == 'client'
      client_id = Client.find_by(public_id: target_public_id).id
      return BusinessClient.find_by(client_id: client_id).business
    end
  end
end
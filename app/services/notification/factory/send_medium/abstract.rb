class Notification::Factory::SendMedium::Abstract
  def send_request
    raise NotImplementedError, "#{self.class}에서 '#{__method__}'(발송하는 함수)를 구현하지 않았습니다."
  end
end
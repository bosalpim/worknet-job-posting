class ExtraBenefitNotificationJob < ApplicationJob
  10.times do |i|
    self.class_eval <<~CODE
      cron "#{i * 5} 3 ? * THU *"
      def send_step_#{i}
        ExtraBenefitNotificationService.call(0.1, #{0.1 * i})
      end
    CODE
  end
end

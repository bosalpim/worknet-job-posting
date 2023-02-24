class PersonalNotificationJob < ApplicationJob
  10.times do |i|
    self.class_eval <<~CODE
      cron "#{i * 5} 3 ? * MON *"
      def send_step_#{i}
        PersonalNotificationService.call(0.1, #{0.1 * i})
      end
    CODE
  end
end

class PersonalNotificationJob < ApplicationJob
  # "From 12:00 on Monday in Korean Time"
  10.times do |i|
    self.class_eval <<~CODE
      cron "#{i * 5} 4 ? * FRI *"
      def send_step_#{i}
        PersonalNotificationService.call(0.1, #{0.1 * i})
      end
    CODE
  end
end

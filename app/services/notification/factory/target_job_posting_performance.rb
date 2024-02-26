class Notification::Factory::TargetJobPostingPerformance < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  def initialize
    super(MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE)
    @list = GetLocalAdsUsersService.call
    create_message
  end

  def create_message
    @list.each do |job_posting|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "케어파트너 대상 공고 : #{job_posting.public_id}\n"
      dispatched_notifications = DispatchedNotification.where(notification_relate_instance_types_id: 3,
                                           notification_relate_instance_id: job_posting.id)
      total_count = dispatched_notifications.count
      read_count = dispatched_notifications.where.not(confirmed: nil)
                                          .count
      if read_count > 0
        job_applications_count = 0
        contact_messages_count = 0
        call_feedbacks_count = 0

        dispatched_notifications.each do |notification|
          receiver_id = notification.receiver_id

          job_applications_count += 1 if JobApplication.exists?(job_posting_id: job_posting.id, user_id: receiver_id)
          contact_messages_count += 1 if ContactMessage.exists?(job_posting_id: job_posting.id, user_id: receiver_id)
          call_feedbacks_count += 1 if CallFeedback.exists?(job_posting_id: job_posting.id, user_id: receiver_id)
        end

        business = Business.find(job_posting.business_id)
        utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
        link = "#{Main::Application::BUSINESS_URL}/recruitment_management/#{job_posting.public_id}/dashboard?#{utm}"
        params = {
          job_posting_id: job_posting.id,
          center_name: business.name,
          target_public_id: job_posting.public_id,
          title: job_posting.title,
          address: get_dong_name_by_address(job_posting.address),
          count: {
            total: total_count,
            read: read_count,
            job_applications: job_applications_count,
            contact_messages: contact_messages_count,
            calls: call_feedbacks_count
          },
          link: link
        }
        Jets.logger.info "전송 완료\n"
        @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, job_posting.manager_phone_number, params, job_posting.public_id, "AI"))
      else
        Jets.logger.info "클릭자가 없기에 전송 취소\n"
      end
      Jets.logger.info "-------------- INFO END --------------\n"
    end
  end
end
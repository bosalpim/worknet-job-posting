class Notification::Factory::TargetJobPostingAdApply < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  def initialize(params)
    super(MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY)
    @job_posting = JobPosting.find(params[:job_posting_id])
    @business = @job_posting.business
    @client = @business.clients.first
    @user = User.find(params[:user_id])
    @application_type = params[:application_type]
    create_message
  end

  def create_message
    Jets.logger.info "-------------- INFO START --------------\n"
    Jets.logger.info "케어파트너 대상 공고 : #{@job_posting.public_id}\n"

    user_info = extract_user_info

    dispatched_notifications = DispatchedNotification.where(notification_relate_instance_types_id: 3,
                                                            notification_relate_instance_id: @job_posting.id)
    total_count = dispatched_notifications.count

    job_applications_count = 0
    contact_messages_count = 0
    user_saves_count = 0

    dispatched_notifications.each do |notification|
      receiver_id = notification.receiver_id

      job_applications_count += 1 if JobApplication.exists?(job_posting_id: job_posting.id, user_id: receiver_id)
      contact_messages_count += 1 if ContactMessage.exists?(job_posting_id: job_posting.id, user_id: receiver_id)
      user_saves_count += 1 if UserSavedJobPosting.exists?(job_posting_id: job_posting.id, user_id: receiver_id)
    end

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    link = "#{Main::Application::BUSINESS_URL}/recruitment_management/#{job_posting.public_id}/dashboard?#{utm}"
    params = {
      job_posting_id: @job_posting.id,
      user_info: user_info,
      user_name: @user.name[0] + "**",
      center_name: @business.name,
      target_public_id: @job_posting.public_id,
      title: @job_posting.title,
      address: get_dong_name_by_address(@job_posting.address),
      count: {
        total: total_count,
        job_applications: job_applications_count,
        contact_messages: contact_messages_count,
        user_saves: user_saves_count
      },
      link: link
    }
    Jets.logger.info "전송 완료\n"
    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, job_posting.manager_phone_number, params, job_posting.public_id, "AI"))
  end

  def extract_user_info
    name = @user.name[0] + "**"
    gender = @user.gender === "male" ? "남성" : "여성"
    age = @job_posting.job_posting_customer.korean_age

    name + "/" + gender + "/" + age
  end
end
class Notification::Factory::TargetJobPostingAdApply < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper

  def initialize(params)
    super(MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY)
    @job_posting = JobPosting.find(params[:job_posting_id])
    @business = @job_posting.business
    @client = @business.clients.first
    @user = User.find(params[:user_id])
    @application_type = params[:application_type]
    @job_application = JobApplication.find(params[:job_application_id]) if params[:job_application_id]
    @contact_message = ContactMessage.find(params[:contact_message_id]) if params[:contact_message_id]
    @user_saved_job_posting = UserSavedJobPosting.find(params[:user_saved_job_posting_id]) if params[:user_saved_job_posting_id]
    create_message
  end

  def create_message
    Jets.logger.info "-------------- INFO START --------------\n"
    Jets.logger.info "케어파트너 대상 공고 : #{@job_posting.public_id}\n"

    user_info = extract_user_info
    application_type = extract_application_type_label

    dispatched_notifications = DispatchedNotification.where(notification_relate_instance_types_id: 3,
                                                            notification_relate_instance_id: @job_posting.id)
    total_count = dispatched_notifications.count

    job_applications_count = 0
    contact_messages_count = 0
    user_saves_count = 0

    dispatched_notifications.each do |notification|
      receiver_id = notification.receiver_id

      job_applications_count += 1 if JobApplication.where(job_posting_id: @job_posting.id, user_id: receiver_id).exists?
      contact_messages_count += 1 if ContactMessage.where(job_posting_id: @job_posting.id, user_id: receiver_id).exists?
      user_saves_count += 1 if UserSavedJobPosting.where(job_posting_id: @job_posting.id, user_id: receiver_id).exists?
    end

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"

    link = if @application_type == 'job_application'
             "#{Main::Application::BUSINESS_URL}/employment_management/job_applications/#{@job_application.public_id}?#{utm}"
           elsif @application_type == 'contact_message'
             "#{Main::Application::BUSINESS_URL}/employment_management/contact_messages/#{@contact_message.public_id}?#{utm}"
           elsif @application_type == 'save'
             "#{Main::Application::BUSINESS_URL}/employment_management/saved_user/#{@user_saved_job_posting.id}?auth_token=#{@user_saved_job_posting.auth_token}&#{utm}"
           else
             "#{Main::Application::BUSINESS_URL}/recruitment_management/#{@job_posting.public_id}/dashboard?#{utm}"
           end

    close_link = "#{Main::Application::BUSINESS_URL}/recruitment_management/#{@job_posting.public_id}/close?#{utm}"

    params = {
      job_posting_id: @job_posting.id,
      user_id: @user.id,
      user_info: user_info,
      application_type: application_type,
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
      link: link,
      close_link: close_link,
    }

    Jets.logger.info params
    Jets.logger.info "전송 완료\n"
    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, @job_posting.manager_phone_number, params, @job_posting.public_id, "AI", nil, [0]))
  end

  def extract_user_info
    name = @user.name[0] + "**"
    gender = @user.gender === "male" ? "남성" : "여성"
    age = @job_posting.job_posting_customer.korean_age

    name + "/" + gender + "/" + age
  end

  def extract_application_type_label
    if @application_type == "job_application"
      "간편지원"
    elsif @application_type == "contact_message"
      "문자문의"
    else
      "관심표시"
    end
  end
end
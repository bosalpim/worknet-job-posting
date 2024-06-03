# frozen_string_literal: true

class Notification::Factory::EmploymentConfirmationService < Notification::Factory::NotificationFactoryClass
  include AlimtalkMessage

  def initialize(params)
    super(MessageTemplateName::CAREER_CERTIFICATION_V3)
    puts "params: ", params
    puts "user_id symbol: ", params[:user_id]
    puts "user_id access: ", params["user_id"]

    @user = User.find(params[:user_id])
    @job_posting = JobPosting.find(params[:job_posting_id])
    @business = @job_posting.business
    @link = params[:link]
    create_message
  end

  def create_message
    reserve_dt = if Jets.env.production? (DateTime.now + 3.days).in_time_zone('Seoul').strftime('%Y%m%d%H%M%S')
                 else nil
                 end
    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, @user.phone_number, { link: @link, job_posting_title: @job_posting.title, center_name: @business.name }, @user.public_id, "AI", reserve_dt, [0]))
  end
end

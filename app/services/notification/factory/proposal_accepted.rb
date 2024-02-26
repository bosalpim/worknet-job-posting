# frozen_string_literal: true

class Notification::Factory::ProposalAccepted < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include JobMatchHelper
  include NotificationType
  include KakaoNotificationLoggingHelper

  def initialize(params)
    super(MessageTemplateName::PROPOSAL_ACCEPT)

    @target_public_id = params['target_public_id']
    @proposal_id = params['proposal_id']
    @business_id = params["business_id"]
    @business_name = params["business_name"]
    @job_posting_id = params["job_posting_id"]
    @job_posting_title = params["job_posting_title"]
    @employee_id = params["employee_id"]
    @phone_number = params["phone_number"]
    @tel_link = params["tel_link"]
    @user_info = params["user_info"]
    @user_name = params["user_name"]
    @accepted_at = params["accepted_at"]
    @address = params["address"]
    @client_message = params["client_message"]
    @job_posting = JobPosting.find_by(public_id: @job_posting_id)
    @user = User.find_by(public_id: @employee_id)
    @proposal = Proposal.find(@proposal_id)
    @client = @job_posting.client
    @is_high_wage = is_high_wage(
      work_type: @job_posting.work_type,
      pay_type: @job_posting.pay_type,
      wage: @job_posting.max_wage
    )
    @is_can_negotiate_work_time = @job_posting.can_negotiate_work_time
    @is_newbie_appliable = is_newbie_appliable(@job_posting.applying_options)
    @is_support_transportation_expences = is_support_transportation_expences(@job_posting.welfare_types)

    create_message
  end

  def create_message
    if @target_medium == APP_PUSH && @client.client_push_tokens.valid.present?
      return create_app_push_message
    end

    create_bizm_message
  end

  def create_app_push_message
    base_url = "#{Main::Application::DEEP_LINK_SCHEME}/redirect/business"
    to = "employment_management/proposals/#{@proposal_id}"
    link = "#{base_url}?to=#{CGI.escape("#{to}?utm_source=message&medium=app_push&utm_campaign=#{@message_template_id}")}"

    @app_push_list.push(
      *@client.client_push_tokens.valid.map do |push_token|
        AppPush.new(
          @message_template_id,
          push_token.token,
          @message_template_id,
          {
            title: '전화면접 제안을 수락했어요!',
            body: '제안을 수락한 요양보호사는 채용 확률이 높으니 지금바로 전화 응답해 보세요.',
            link: link,
          },
          @client.public_id,
          {
            "type" => NOTIFICATION_TYPE_APP_PUSH,
            "template" => @message_template_id,
            "centerName" => @business_name,
            "jobPostingId" => @job_posting_id,
            "title" => @job_posting_title,
            "employee_id" => @employee_id,
            "message" => @client_message,
            "highWage" => @is_high_wage,
            "canNegotiateWorkTime" => @is_can_negotiate_work_time,
            "transportationExpenses" => @is_support_transportation_expences,
            "canApplyNewBie" => @is_newbie_appliable
          }
        )
      end
    )

  end

  def create_bizm_message
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    link = "#{Main::Application::BUSINESS_URL}/employment_management/proposals/#{@proposal_id}?#{utm}"
    close_link = "#{Main::Application::HTTPS_BUSINESS_URL}/recruitment_management/#{@job_posting_id}/close?#{utm}"

    params = {
      target_public_id: @target_public_id,
      employee_id: @employee_id,
      job_posting_id: @job_posting_id,
      job_posting_title: @job_posting_title,
      business_name: @business_name,
      link: link,
      close_link: close_link,
      user_name: @user_name,
      user_info: @user_info,
      accepted_at: @accepted_at,
      address: @address,
      client_message: @client_message,
      proposal_id: @proposal_id,
      is_high_wage: is_high_wage(
        work_type: @job_posting.work_type,
        pay_type: @job_posting.pay_type,
        wage: @job_posting.max_wage
      ),
      is_can_negotiate_work_time: @job_posting.can_negotiate_work_time,
      is_newbie_appliable: is_newbie_appliable(@job_posting.applying_options),
      is_support_transportation_expences: is_support_transportation_expences(@job_posting.welfare_types),
    }

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @job_posting.manager_phone_number,
        params,
        @client.public_id, "AI"
      )
    )
  end
end

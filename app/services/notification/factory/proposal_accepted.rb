# frozen_string_literal: true

class Notification::Factory::ProposalAccepted < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include JobMatchHelper
  include Notification

  def initialize(params)
    super(MessageTemplateName::CALL_INTERVIEW_ACCEPTED)

    @target_public_id = params['target_public_id']
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
    @proposal = Proposal.find_by(
      user_id: @user.id,
      job_posting_id: @job_posting_id
    )
    @client = @job_posting.client

    create_message
  end

  def create_message
    if @target_medium == APP_PUSH && @client.client_push_tokens.valid.present?
      return create_app_push_message
    end

    create_bizm_message
  end

  def create_app_push_message

    @app_push_list.push(
      *@client.client_push_tokens.valid.map do |push_token|
        AppPush.new(
          @message_template_id,
          push_token.token,
          @message_template_id,
          {
            title: '내가 보낸 전화면접 제안을 요양보호사가 수락했어요!',
            body: '제안을 수락한 요양보호사는 채용 확률이 높으니 지금바로 전화 응답해 보세요.',
            link: @tel_link,
          },
          @client.public_id,
        )
      end
    )

  end

  def create_bizm_message
    params = {
      target_public_id: @target_public_id,
      employee_id: @employee_id,
      job_posting_id: @job_posting_id,
      job_posting_title: @job_posting_title,
      business_name: @business_name,
      tel_link: @tel_link,
      user_name: @user_name,
      user_info: @user_info,
      accepted_at: @accepted_at,
      address: @address,
      client_message: @client_message,
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

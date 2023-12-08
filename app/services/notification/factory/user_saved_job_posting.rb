# frozen_string_literal: true

class Notification::Factory::UserSavedJobPosting < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include JobMatchHelper
  include Notification

  def initialize(params)
    super(MessageTemplateName::CALL_SAVED_JOB_CAREGIVER)

    @phone = params["phone"]
    @template_params = {
      # 센터 정보
      target_public_id: params["client_public_id"],
      center_name: params["center_name"],
      job_posting_public_id: params["job_posting_public_id"],
      job_posting_title: params["job_posting_title"],
      # 요보사 정보
      user_public_id: params["user_public_id"],
      user_name: params["user_name"],
      user_career: params["user_career"],
      user_gender: params["user_gender"],
      user_age: params["user_age"],
      user_address: params["user_address"],
      user_distance: params["user_distance"],
      # 공고 & 요보사 사이 매칭 정보
      type_match: params["type_match"],
      gender_match: params["gender_match"],
      day_match: params["day_match"],
      time_match: params["time_match"],
      grade_match: params["grade_match"],
      url_path: params["url_path"]
    }
    create_message
  end

  def create_message
    if @target_medium == APP_PUSH && @client.client_push_tokens.valid.present?
      return create_app_push
    end

    create_bizm_message
  end

  def create_push_message
    link = "#{@template_params[:url_path]}&utm_source=message&utm_medium=app_push&utm_campaign=call_saved_job_caregiver"

    @app_push_list.push(
      @client.client_push_tokens.valid.map do |push_token|
        AppPush.new(
          @message_template_id,
          push_token.token,
          @message_template_id,
          {
            title: '요양보호사가 공고에 관심 표시했어요!',
            body: '지금바로 공고에 관심 표시한 요양보호사에게 무료로 전화해보세요.',
            link: link,
          },
          @client.public_id,
        )
      end
    )

  end

  def create_bizm_message

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @job_posting.manager_phone_number,
        @template_params,
        @client.public_id, "AI"
      )
    )
  end
end

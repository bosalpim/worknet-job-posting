# frozen_string_literal: true

class Notification::Factory::SmartMemo < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include ApplicationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper

  def initialize(params)
    super(MessageTemplateName::SMART_MEMO)
    @job_posting = JobPosting.find(params[:job_posting_id])
    @user = User.find(params[:user_id])
    @job_postings_connect = JobPostingsConnect.find(params[:job_postings_connect_id])
    @call_record = CallRecord.find(params[:call_record_id])
    @business = JobPosting.business
    @client = @business.clients.first
    @target_medium = MessageTemplate.find_by(name: @message_template_id)&.target_medium

    create_message
  end

  def create_message
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    link = "#{BUSINESS_URL}/smart-memo?#{utm}"

    params = {
      link: link,
      target_public_id: @client.public_id,
      user_name: @user.name,
      user_age: calculate_korean_age(@user.birth_year),
      user_gender: @user.korean_gender,
      indur: @call_record.indur,
      connected_at: @job_postings_connect.connected_at,
      user_public_id: @user.public_id,
      job_posting_public_id: @job_posting.public_id,
      job_postings_connect_id: @job_postings_connect.id,
      connect_type: @job_postings_connect.connect_type,
      business_name: @business.name
    }

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @job_posting.manager_phone_number,
        params,
        @client.public_id, 'AI'
      ))
  end

end

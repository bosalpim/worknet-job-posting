# frozen_string_literal: true

class Notification::Factory::SmartMemo < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include ApplicationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper

  def initialize(params)
    super(MessageTemplateName::SMART_MEMO)

    Jets.logger.info "-----"
    Jets.logger.info params
    Jets.logger.info "-----"
    Jets.logger.info "#1 -----"
    Jets.logger.info params["job_posting_id"]
    Jets.logger.info "#2 -----"
    Jets.logger.info params[:job_posting_id]

    @job_posting = JobPosting.find(params[:job_posting_id])
    @user = User.find(params[:user_id])
    @job_postings_connect = JobPostingsConnect.find(params[:job_postings_connect_id])
    @call_record = CallRecord.find(params[:call_record_id]) if params[:call_record_id].present?
    @bizcall_callback = BizcallCallback.find(params[:bizcall_callback_id]) if params[:bizcall_callback_id].present?
    @business = @job_posting.business
    @client = @business.clients.first
    @target_medium = MessageTemplate.find_by(name: @message_template_id)&.target_medium

    create_message
  end

  def create_message
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    link = "#{BUSINESS_URL}/smart-memo?#{utm}"
    connected_at = @job_postings_connect.connected_at
    connected_at = DateTime.parse(connected_at.to_s)
    connected_at_text = [
      "#{connected_at.year}년",
      "#{connected_at.month}월",
      "#{connected_at.day}일",
      "#{connected_at.hour < 12 ? '오전' : '오후'}",
      "#{connected_at.hour == 12 ? '12시' : "#{connected_at.hour % 12}시"}",
      "#{connected_at.minute}분"
    ].join(" ")

    indur = @call_record&.indur || @bizcall_callback&.indur
    params = {
      link: link,
      target_public_id: @client.public_id,
      user_name: @user.name,
      user_age: calculate_korean_age(@user.birth_year),
      user_gender: @user.korean_gender,
      indur: indur,
      indur_minute: (indur / 60).ceil,
      connected_at: @job_postings_connect.connected_at,
      connected_at_text: connected_at_text,
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

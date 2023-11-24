class NotifyJobPostingSavedUserService
  include Notification

  def self.call(event)
    new(event).call
  end

  def initialize(event)
    @event = event
    @template_id = MessageTemplateName::CALL_SAVED_JOB_CAREGIVER
  end

  def call
    fail_reasons = []
    success_count = 0
    fail_count = 0

    phone = @event["phone"]

    response = BizmsgService.call(
      template_id: @template_id,
      phone: phone,
      template_params: {
        # 센터 정보
        target_public_id: @event["client_public_id"],
        center_name: @event["center_name"],
        job_posting_public_id: @event["job_posting_public_id"],
        job_posting_title: @event["job_posting_title"],
        # 요보사 정보
        user_public_id: @event["user_public_id"],
        user_name: @event["user_name"],
        user_career: @event["user_career"],
        user_gender: @event["user_gender"],
        user_age: @event["user_age"],
        user_address: @event["user_address"],
        user_distance: @event["user_distance"],
        # 공고 & 요보사 사이 매칭 정보
        type_match: @event["type_match"],
        gender_match: @event["gender_match"],
        day_match: @event["day_match"],
        time_match: @event["time_match"],
        grade_match: @event["grade_match"],
        url_path: @event["url_path"]
      },
      message_type: "AI"
    )

    if response.dig("result") == "Y"
      if response.dig("code") == "K000"
        success_count += 1
      end
    else
      fail_count += 1
      fail_reasons.push("userid: #{@user_public_id}, error: #{response.dig("error")}")
    end

    NotificationResult.create!(
      send_type: NotificationResult::CALL_SAVED_JOB_CAREGIVER,
      template_id: @template_id,
      success_count: success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(",")
    )
  end
end
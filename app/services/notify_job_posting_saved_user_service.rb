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

    host = if Jets.env.production?
             'https://business.carepartner.kr'
           elsif Jets.env.staging?
             'https://staging-business.vercel.app'
           else
             'http://localhost:3001'
           end

    utm_part = 'utm_source=text_message&utm_medium=text_message&utm_campaign=call_saved_job_caregiver'
    send_text_message(
      phone_number: phone,
      user_name: @event["user_name"],
      user_gender: @event["user_gender"],
      user_age: @event["user_age"],
      job_posting_title: @event["job_posting_title"],
      career: @event["user_career"],
      distance: @event["user_distance"],
      address: @event["user_address"],
      url: ShortUrl.build("#{host}#{@event["url_path"]}&#{utm_part}", host).url
    )

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

  private

  def send_text_message(
    phone_number:,
    user_name:,
    user_gender:,
    user_age:,
    job_posting_title:,
    career:,
    distance:,
    address:,
    url:
  )
    # todo 효과좋으면 리팩토링 필요
    if Lms.new(
      phone_number: phone_number,
      message: "#{user_name}  요양보호사가 아래 공고에 관심을 표시했어요!

공고 : #{job_posting_title}

■ 기본 정보 : #{user_name} / #{user_gender} / #{user_age}
■ 근무 경력 : #{career}
■ 통근 거리 : #{distance}
■ 거주 주소 : #{address}

아래 주소로 접속해 공고에 관심표시한 요양보호사에게 지금 바로 전화해보세요!

주소: #{url}"
    ).send
      AmplitudeService.instance.log_array([{
                                             "user_id" => @event["client_public_id"],
                                             "event_type" => KakaoNotificationLoggingHelper::NOTIFICATION_EVENT_NAME,
                                             "event_properties" => {
                                               type: 'text_message',
                                               center_name: @event["center_name"],
                                               jobPostingId: @event["job_posting_public_id"],
                                               title: @event["job_posting_title"],
                                               employee_id: @event["user_public_id"],
                                               template: MessageTemplateName::CALL_SAVED_JOB_CAREGIVER,
                                             }
                                           }])
    end
  end
end
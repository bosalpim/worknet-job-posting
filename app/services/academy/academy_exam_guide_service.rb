# frozen_string_literal: true

class Academy::AcademyExamGuideService
  def call
    target_users = find_exam_target_users

    target_users.each do |result|
      send_notification(result)
    end
  end

  private

  def send_notification(result)
    response = KakaoNotificationService.call(
      template_id: MessageTemplateName::ACADEMY_EXAM_GUIDE,
      phone: result['phone_number'],
      message_type: 'AI',
      template_params: {
        user_name: result['user_name'].presence || '수강생',
        course_title: result['course_title'],
        video_watched_ratio: "#{(result['video_watched_ratio'] * 100).floor(1)}",
        link: 'https://www.carepartner.kr/academy/my?tab=courses'
      },
      profile: "CareAcademy",
    )

    save_notification_result(response, result['user_id'])
  end

  def save_notification_result(response, user_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reason = ""

    if response.dig("code") == "success"
      if response.dig("message") == "K000"
        success_count += 1
      else
        tms_success_count += 1
      end
    else
      fail_count += 1
      fail_reason = response.dig("originMessage")
    end

    NotificationResult.create!(
      send_type: NotificationResult::ACADEMY_EXAM_GUIDE,
      send_id: user_id,
      template_id: MessageTemplateName::ACADEMY_EXAM_GUIDE,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reason
    )
  end

  def find_exam_target_users
    results = ActiveRecord::Base.connection.execute(<<-SQL)
WITH course_progress AS (
  SELECT 
    ac.id as course_id,
    ac.title as course_title,
    gl.user_id,
    gl.progress_rate as video_watched_ratio
  FROM academy_courses ac, get_course_leaderboard(ac.id::int) gl
  WHERE ac.status = 'ACTIVE'
),
not_attempted AS (
  SELECT DISTINCT cp.course_id, cp.user_id
  FROM course_progress cp
  JOIN academy_courses ac ON ac.id = cp.course_id
  WHERE NOT EXISTS (
    SELECT 1 
    FROM academy_exam_attempts aea
    JOIN academy_exams ae ON ae.id = aea.exam_id
    WHERE aea.user_id = cp.user_id
    AND ae.certification_id = ac.certification_id
  )
),
notified_users AS (
  SELECT DISTINCT send_id::bigint AS user_id
  FROM notification_results
  WHERE template_id = '#{MessageTemplateName::ACADEMY_EXAM_GUIDE}'
)
SELECT 
  cp.course_title,
  cp.user_id,
  u.name as user_name,
  u.phone_number,
  cp.video_watched_ratio
FROM course_progress cp
JOIN not_attempted na ON na.course_id = cp.course_id AND na.user_id = cp.user_id
JOIN users u ON u.id = cp.user_id
LEFT JOIN notified_users nu
  ON nu.user_id = u.id
WHERE cp.video_watched_ratio >= 0.5
  AND nu.user_id IS NULL;
    SQL
  end
end
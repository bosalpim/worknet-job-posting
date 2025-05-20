# frozen_string_literal: true

class UserPushAlertQueuePrepareJob < ApplicationJob
  # user_push_alert_queues table에 전송을 위한 데이터를 넣는 사전 준비 job입니다.
  # 메세지 보내는 시간 최소 15분 전에 실행해야 합니다.

  cron "0 23 * * ? *"
  def quiz_5_push_alert
    prepare_user_push_alert("quiz_5")
  end

  cron "30 9 * * ? *"
  def prepare_yoyang_run_push_alert
    prepare_user_push_alert("yoyang_run")
  end

  cron "30 23 * * ? *"
  def prepare_zodiac_push_alert
    prepare_user_push_alert("daily_chinese_zodiac_fortune")
  end

  cron "30 11 * * ? *"
  def prepare_7d_checkin_push_alert
    prepare_user_push_alert("7_daily_check_in")
  end

  cron "30 2 * * ? *"
  def prepare_cp_roulette_12
    prepare_user_push_alert("coupang_roulette")
  end

  cron "30 8 * * ? *"
  def prepare_cp_roulette_18
    prepare_user_push_alert("coupang_roulette")
  end

  cron "30 11 * * ? *"
  def prepare_cp_roulette_21
    prepare_user_push_alert("coupang_roulette")
  end

  cron "40 8 * * ? *"
  def prepare_academy_boost_alert
    query = User.joins(:user_push_tokens)
                .joins("INNER JOIN academy_course_enrollments ON academy_course_enrollments.user_id = users.id")
                .joins("INNER JOIN academy_courses ON academy_courses.id = academy_course_enrollments.course_id")
                .joins("INNER JOIN academy_videos av ON av.course_id = academy_course_enrollments.course_id")
                .joins("LEFT JOIN academy_course_video_progresses acvp ON acvp.video_id = av.id AND acvp.user_id = users.id")
                .select("academy_courses.id as course_id, academy_courses.title, users.name, users.id, 
                        academy_course_enrollments.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul' as created_at,
                        CURRENT_DATE - (academy_course_enrollments.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul')::date as days_since_enrollment,
                        user_push_tokens.token,
                        COALESCE(sum(acvp.watched_ratio), 0) / count(av.id) as avg_watched_ratio")
                .where("(academy_course_enrollments.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul')::date >= CURRENT_DATE - INTERVAL '7 days'
                        AND (academy_course_enrollments.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul')::date <= CURRENT_DATE
                        AND academy_course_enrollments.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul' >= '2025-05-19'")
                .group("academy_courses.id, academy_courses.title, users.name, users.id, 
                        academy_course_enrollments.created_at, user_push_tokens.token")
                .having("COALESCE(sum(acvp.watched_ratio), 0) / count(av.id) <= ?", 0.5)
                .order("days_since_enrollment")
                

      # 실제 SQL 쿼리 출력
      # puts "Generated SQL:"
      # puts query.to_sql

      # 쿼리 실행
      users = query.to_a

      # users의 카운터를 로그로 출력
      puts "users의 카운터: #{users.count}"

      # user_data 속성 추가
      users.each do |user|
        user.instance_variable_set(:@user_data, {
          days_since_enrollment: user.days_since_enrollment,
          course_id: user.course_id
        })
        def user.user_data
          @user_data
        end
      end
  
      prepare_user_push_alert("academy_boost", users)
  end

  def prepare_user_push_alert(alert_name, users = nil)
    if Jets.env.production?
      UserPushAlert::BaseClass.new(
        alert_name: alert_name,
        date: DateTime.now,
        users: users
        ).prepare
    elsif Jets.env.staging?
      UserPushAlert::BaseClass.new(
        alert_name: alert_name,
        date: DateTime.now,
        batch: 2,
        users: users
      ).prepare
    end
  end

end

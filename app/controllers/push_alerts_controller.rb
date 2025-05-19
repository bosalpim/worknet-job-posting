# frozen_string_literal: true

module UserPushAlert
  class AcademyBoost
    def self.prepare
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
  
      prepare_user_push_alert_academy("academy_boost", users)
    end

    def self.prepare_user_push_alert_academy(alert_name, users = nil)
      if Jets.env.production?
        UserPushAlert::BaseClass.new(
          alert_name: alert_name,
          date: DateTime.now,
          users: users
        ).prepare
      else Jets.env.staging?
        UserPushAlert::BaseClass.new(
          alert_name: alert_name,
          date: DateTime.now,
          batch: 2,
          users: users
        ).prepare
      end
    end
  end
end

class PushAlertsController < ApplicationController
  def prepare_academy_boost
    UserPushAlert::AcademyBoost.prepare

    render json: { message: "Academy boost push alert prepared successfully" }
  end
end

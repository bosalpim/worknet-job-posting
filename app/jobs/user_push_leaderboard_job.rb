# frozen_string_literal: true

class LeaderboardPushAlert
  def self.send_push
    current_time = Time.current
    Jets.logger.info "Leaderboard data generated at: #{current_time}"
    Jets.logger.info "Current timezone: #{current_time.zone}"

    # 강의 누적 진도율 50% 이하 &
    # 2주 이내 수강 이력이 있으면서 &
    # D-1에 수강이력이 없으면 D-0 아침 9시에 알림을 보낸다.
    results = ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT	distinct u.public_id, t."token"
      FROM	get_course_leaderboard() l
      JOIN	users u on u.id = l.user_id
      join    user_push_tokens t on t.user_id = u.id
      WHERE	progress_rate < 0.5
      AND		last_watched_at >= now() - interval '14 days'
      AND		last_watched_at < now() - interval '1 day'
    SQL

    user_infos = results.map do |row|
      { public_id: row['public_id'], token: row['token'] }
    end

    # 서비스에 유저 리스트를 한 번에 넘김
    notification = Notification::Factory::AcademyLeaderboardPushService.new(user_infos: user_infos)
    notification.create_message
    notification.notify # 한 번에 발송
    Jets.logger.info "총 #{user_infos.size}명에게 푸시 발송"
  end
end

class UserPushLeaderboardJob < ApplicationJob
  
  cron "0 0 * * ? *"
  def leaderboard_push_alert_job
    LeaderboardPushAlert.send_push
  end

  # API 호출을 위한 클래스 메소드
  def self.run
    LeaderboardPushAlert.send_push
  end
end 
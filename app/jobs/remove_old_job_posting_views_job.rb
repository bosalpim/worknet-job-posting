# frozen_string_literal: true

class RemoveOldJobPostingViewsJob < ApplicationJob
  cron "0 0 * * *" # 매일 자정에 실행

  def run
    # 기준 날짜 설정 (현재 날짜에서 한 달 전)
    cutoff_date = 1.month.ago

    # 한 달 이상 된 jobPostingViews 레코드 삭제
    old_views = JobPostingView.where('created_at < ?', cutoff_date)
    old_views_count = old_views.count

    old_views.delete_all

    Jets.logger.info "Removed #{old_views_count} job posting views older than one month."
  end
end

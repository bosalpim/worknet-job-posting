# frozen_string_literal: true

class AcademyExamJob < ApplicationJob
  # 매일 아침 8시에 실행
  cron "0 23 * * ? *"

  def academy_exam_guide
    Academy::AcademyExamGuideService.new.call
  end

  # 매일 아침 8시에 실행
  cron "0 23 * * ? *"

  def academy_exam_transition
    Academy::AcademyExamTransitionService.new.call
  end
end

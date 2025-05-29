# frozen_string_literal: true

class AcademyExamJob < ApplicationJob
  # 매일 아침 8시에 실행
  cron "0 23 * * ? *"

  def academy_exam_guide
    Academy::AcademyExamGuideService.new.call
  end

  # 매일 아침 8시에 실행
  # TODO: cron "0 23 * * ? *"

  def academy_exam_transition
    Academy::AcademyExamTransitionService.new.call
  end

  # 테스트용으로 오후 3시에 발송
  cron "0 6 * * ? *"

  def academy_exam_guide_test(event:)
    user = User.where('phone_number = ?', event['phone_number'] || '01020748127').first

    KakaoNotificationService.call(
      template_id: MessageTemplateName::ACADEMY_EXAM_GUIDE,
      phone: user.phone_number,
      message_type: 'AI',
      template_params: {
        user_name: user.name.presence || '수강생',
        course_title: "병행동행매니저",
        video_watched_ratio: "56.7",
        link: 'https://www.carepartner.kr/academy/my?tab=courses',
        target_public_id: user.public_id,
      },
      profile: "CareAcademy",
      )
  end
end

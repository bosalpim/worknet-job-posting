class CallFeedback < ApplicationRecord
  belongs_to :job_posting
  belongs_to :user

  enum type: {
    not_active: 'not_active', # 구직중이 아님
    not_matched: 'not_matched', # 조건에 맞지 않음
    interview_scheduled: 'interview_scheduled', # 면접 예정
    not_answering: 'not_answering' # 부재중임
  }
end

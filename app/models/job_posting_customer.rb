class JobPostingCustomer < ApplicationRecord
  belongs_to :job_posting

  enum gender: { male: 'male', female: 'female' }

  enum grade: {
    none: 'none',
    first: 'first',
    second: 'second',
    third: 'third',
    fourth: 'fourth',
    fifth: 'fifth',
    sixth: 'sixth',
  },
       _suffix: true

  enum cognitive_disorder: {
    no_dementia: 'no_dementia',
    early_stage_dementia: 'early_stage_dementia',
    mid_stage_dementia: 'mid_stage_dementia',
    end_stage_dementia: 'end_stage_dementia',
  }
  enum cohabiting_family: {
    live_alone: 'live_alone',
    spouse_exist_on_service: 'spouse_exist_on_service',
    spouse_not_exist_on_service: 'spouse_not_exist_on_service',
    family_exist_on_service: 'family_exist_on_service',
    family_not_exist_on_service: 'family_not_exist_on_service',
  }
  ENVIRONMENT_OPTIONS = %w[housekeeper parking_enabled has_pet over_102sqm]

  MEAL_ASSISTANCES = %w[
    self_meal
    prepare_required
    cooking_required
    tube_feeding
  ]
  EXCRETION_ASSISTANCES = %w[
    self_excretion
    help_required
    use_diaper
    indwelling_catheter
  ]
  MOVEMENT_ASSISTANCES = %w[self_movement help_required wheelchair invalidity]

  HOUSEWORK_ASSISTANCES = %w[
    cleaning
    bath
    going_hospital
    walk_exercise
    crony
    cognitive_stimulation_training
  ]

  def korean_grade
    if first_grade?
      '1등급'
    elsif second_grade?
      '2등급'
    elsif third_grade?
      '3등급'
    elsif fourth_grade?
      '4등급'
    elsif fifth_grade?
      '5등급(치매교육필수)'
    elsif sixth_grade?
      '인지지원등급'
    else
      nil
    end
  end

  def korean_age
    if age.present?
      "#{DateTime.now.in_time_zone('Asia/Seoul').year.to_i - age}세"
    else
      nil
    end
  end

  def korean_gender
    if male?
      '남자'
    elsif female?
      '여자'
    else
      nil
    end
  end

  def korean_summary
    [korean_grade, korean_age, korean_gender].select { |item| item.present? }.join('/')
  end
end

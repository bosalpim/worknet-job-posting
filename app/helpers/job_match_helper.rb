module JobMatchHelper
  HIGH_WAGE_MAP = {
    "commute" => {
      pay_type: 'hourly',
      wage: 13_000
    },
    "bath_help" => {
      pay_type: 'hourly',
      wage: 20_000
    },
    "resident" => {
      pay_type: 'monthly',
      wage: 3_400_000
    },
    "day_care" => {
      pay_type: 'monthly',
      wage: 2_200_000
    },
    "sanatorium" => {
      pay_type: 'monthly',
      wage: 2_300_000
    }
  }

  MORNING = 'morning'
  EARLY_AFTERNOON = 'early_afternoon'
  LATE_AFTERNOON = 'late_afternoon'
  EVENING = 'evening'
  OTHERS = 'others'

  JOB_SEARCH_TIME_HOURS = {
    MORNING => [8, 12],
    EARLY_AFTERNOON => [12, 15],
    LATE_AFTERNOON => [15, 18],
    EVENING => [18, 24],
    OTHERS => [0, 0]
  }

  class MatchInfo
    include JobMatchHelper

    def initialize(
      user:,
      job_posting:
    )

      unless user.is_a?(User) && job_posting.is_a?(JobPosting)
        return
      end

      @type_match = is_type_match(user.preferred_work_types, job_posting.work_type)
      @time_match = is_time_match(
        work_start_time: job_posting.work_start_time,
        work_end_time: job_posting.work_end_time,
        job_search_times: user.job_search_times)
      @day_match = is_day_match(
        user.job_search_days,
        job_posting.working_days
      )
      @gender_match = is_gender_match(
        user.preferred_gender,
        job_posting.gender
      )
      @grade_match = is_grade_match(
        user.preferred_grades,
        job_posting.grade
      )
      @distance_match = is_distance_match(
        user.preferred_distance,
        user.distance_from(job_posting)
      )
    end

    def to_hash
      {
        time_match: @time_match,
        day_match: @day_match,
        distance_match: @distance_match,
        type_match: @type_match,
        grade_match: @grade_match,
        distance_match: @distance_match
      }
    end
  end

  def is_time_match(work_start_time:, work_end_time:, job_search_times:)
    return nil if [work_start_time, work_end_time, job_search_times].any?(&:nil?)

    start_time = work_start_time.is_a?(String) ? Time.parse(work_start_time) : work_start_time
    end_time = work_end_time.is_a?(String) ? Time.parse(work_end_time) : work_end_time

    [
      MORNING,
      EARLY_AFTERNOON,
      LATE_AFTERNOON,
      EVENING
    ].select { |time| job_search_times.include?(time) }
     .reduce([]) do |acc, cur|
      start_hour, end_hour = JOB_SEARCH_TIME_HOURS[cur]

      if acc.empty?
        [[start_hour, end_hour]]
      else
        last_start_hour, last_end_hour = acc.pop

        if last_end_hour == start_hour
          acc.push([last_start_hour, end_hour])
        else
          acc.push([last_start_hour, last_end_hour], [start_hour, end_hour])
        end

        acc
      end
    end
      .any? do |start_hour, end_hour|
      start_time.hour >= start_hour && end_time.hour <= end_hour
    end
  end

  def is_type_match(preferred_work_types, job_posting_work_type)
    unless preferred_work_types.is_a?(Array) and job_posting_work_type.present?
      return nil
    end

    return preferred_work_types.include?(job_posting_work_type)
  end

  def is_gender_match(preferred_gender, job_posting_gender)
    unless preferred_gender.present? and job_posting_gender.present?
      return nil
    end

    if preferred_gender == 'all'
      return true
    else
      return preferred_gender == job_posting_gender
    end
  end

  def is_day_match(job_search_days, job_posting_working_days)
    unless job_search_days.present? and job_posting_working_days
      return nil
    end

    search_days_set = Set.new(job_search_days)
    working_days_set = Set.new(job_posting_working_days)

    search_days_set.subset?(working_days_set)
  end

  # done
  def is_grade_match(preferred_grades, job_posting_grade)
    unless preferred_grades.present? and job_posting_grade.present?
      return nil
    end

    preferred_grades.include?(job_posting_grade)
  end

  def is_distance_match(preferred_distance, job_distance)
    unless preferred_distance.present? and job_distance.present?
      return nil
    end

    if (preferred_distance == 'by_walk15')
      (job_distance / 60) < 15
    elsif (preferred_distance == 'by_walk30')
      (job_distance / 60) < 30
    elsif (preferred_distance == 'by_km_3')
      (job_distance < 3000)
    elsif (preferred_distance == 'by_km_5')
      (job_distance < 5000)
    else
      false
    end
  end

  def is_high_wage(work_type:, pay_type:, wage:)
    high_wage_info = HIGH_WAGE_MAP.dig(work_type)

    if high_wage_info.dig(:pay_type) != pay_type
      return false
    end

    return high_wage_info.wage >= wage

  rescue nil
  end

  def is_support_transportation_expences(welfare_types = [])
    return welfare_types.include?("transportation_expenses")

  rescue nil
  end

  def is_newbie_appliable(applying_options = [])
    return applying_options.include?("newbie")

  rescue nil
  end

end

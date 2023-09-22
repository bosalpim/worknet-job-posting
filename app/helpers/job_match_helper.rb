# frozen_string_literal: true

module JobMatchHelper
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

  def is_time_match(work_start_time:, work_end_time:, job_search_times:)
    return nil if [work_start_time, work_end_time, job_search_times].any?(&:nil?)

    start_time = work_start_time.is_a?(String) ? Time.parse(work_start_time) : work_start_time
    end_time = work_end_time.is_a?(String) ? Time.parse(work_end_time) : work_end_time

    start_time -= 9 * 3600
    end_time -= 9 * 3600

    times_to_check = [
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
end

include TranslationHelper
include DayHelper
include ActionView::Helpers::NumberHelper

module JobPostingsHelper
  def get_pay_text(object)
    min_wage = object.min_wage
    max_wage = object.max_wage

    if min_wage.present? && max_wage.present?
      pay_type_text =
        I18n.t("activerecord.attributes.job_posting.pay_type.#{object.pay_type}")
      if min_wage > 0 && max_wage > 0 && min_wage != max_wage
        return(
          pay_type_text + " " + convert_currency(object.min_wage) + '~' +
            convert_currency(object.max_wage)
        )
      elsif min_wage > 0
        return(
          pay_type_text + " " + number_to_currency(object.min_wage, precision: 0)
        )
      else
        object.scraped_worknet_job_posting&.info&.dig('pay_text')
      end
    else
      object.scraped_worknet_job_posting&.info&.dig('pay_text')
    end
  end

  def get_hours_text(object)
    if !object.normal?
      I18n.t("activerecord.attributes.job_posting.working_hours_type.#{object.working_hours_type}")
    elsif object.work_start_time && object.work_end_time
      object.work_start_time&.strftime('%H:%M') + '~' + object.work_end_time&.strftime('%H:%M')
    else
      object.scraped_worknet_job_posting&.info&.dig('hours_text')
    end
  end

  def get_days_text(object)
    if object.worknet_job_posting?
      object.scraped_worknet_job_posting&.info&.dig('days_text')
    else
      format_consecutive_dates(object)
    end
  end

  def get_distance_text(object)
    return nil if object.try(:distance).blank?

    minute = (distance / 60).to_i

    if distance < 60
      '도보 0분 ~ 3분'
    elsif distance < 1800
      "도보 #{minute}분 ~ #{minute + 5}분"
    else
      "도보 30분 이상"
    end
  end

  def get_welfare_text(object)
    if object.worknet_job_posting?
      object.scraped_worknet_job_posting&.info&.dig('welfare_text')
    else
      translate_type('job_posting', object, :welfare_types)
    end
  end

  def convert_currency(number)
    result = number_to_currency(number, precision: 0)
    if number.blank? || !number.is_a?(Integer)
      return nil
    elsif number >= 100_000 && number % 1000 == 0
      thousands = number % 1_000
      result = "#{number / 10_000}만"
      result += "#{number / 1_000}천" unless thousands&.zero?
      result = "#{result}원"
    end
    result
  end

  def calculate_korean_age(birth_year)
    return nil if birth_year.blank?

    return DateTime.now.year - birth_year
  end

  def cognitive_disorder_text(cognitive_disorder)
    case cognitive_disorder
    when "no_dementia"
      return "치매 증상 없음"
    when "early_stage_dementia"
      return "치매 초기"
    when "mid_stage_dementia"
      return "치매 중기"
    when "end_stage_dementia"
      return "치매 말기"
    else
      return nil
    end
  end

  def format_consecutive_dates(object)
    week_days = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    }.with_indifferent_access

    sorted = object.working_days.sort { |a, b| week_days[a] <=> week_days[b] }

    consecutive = false

    sorted.each_with_index do |day, index|
      if index > 0
        if week_days[day] - 1 == week_days[sorted[index - 1]]
          consecutive = true
        else
          consecutive = false
          break
        end
      end
    end

    if consecutive
      I18n.t(
        "activerecord.attributes.job_posting.working_days.#{sorted.first}",
      ) + '~' +
        I18n.t(
          "activerecord.attributes.job_posting.working_days.#{sorted.last}",
        ) + " (주 #{object.working_days.count}일)"
    else
      translate_type('job_posting', object, :working_days) +
        " (주 #{object.working_days.count}일)"
    end
  rescue => e
    nil
  end

  def transport_types(attributes, name, model_name = 'job_posting')
    return nil if attributes.blank?

    attributes
      .map do |attr|
      I18n.t("activerecord.attributes.#{model_name}.#{name}.#{attr}")
    end
      .join(', ')
  end

  def get_dong_name_by_address(address)
    dong = address.split(' ')&.slice(2, 1).first
    dong.nil? ? "" : dong
  end

  def get_work_content(job_posting_customer)
    "#{translate_type('job_posting_customer', job_posting_customer, :meal_assistances)}
#{translate_type('job_posting_customer', job_posting_customer, :excretion_assistances)}
#{translate_type('job_posting_customer', job_posting_customer, :housework_assistances)}
#{translate_type('job_posting_customer', job_posting_customer, :movement_assistances)}"
  end

  def create_customer_info(job_posting_customer)
    basis_customer_info = "#{translate_type('job_posting_customer', job_posting_customer, :grade) || '등급없음'}, #{calculate_korean_age(job_posting_customer&.age) || '미상의연'}세, #{translate_type('job_posting_customer', job_posting_customer, :gender) || '성별미상'}"
    cognitive_disorder_value = cognitive_disorder_text(job_posting_customer.cognitive_disorder)
    basis_customer_info += ", #{cognitive_disorder_text(job_posting_customer.cognitive_disorder)}" unless cognitive_disorder_value.nil?

    basis_customer_info
  end

  def vacation_day_resident(job_posting)
    missing_day_text = translate_type('job_posting',nil, 'working_days', missing_days(job_posting.working_days))
    missing_day_text.nil? ? "" : ", #{translate_type('job_posting',nil, 'working_days', missing_days(job_posting.working_days)).gsub(/[[:space:]]/, "").gsub(",", "/")}요일 휴무"
  end
end
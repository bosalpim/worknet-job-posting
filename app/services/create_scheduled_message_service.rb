class CreateScheduledMessageService
  attr_reader :template_id, :send_type

  BATCH_SIZE = 1_500.freeze
  def initialize(template_id, send_type)
    @template_id = template_id
    @send_type = send_type
  end

  def save_call
    # user를 찾되 batch로 돌려서 나눠서 찾는다.
    users = User.active.receive_notifications.where(has_certification: true).order(:created_at)
    users.find_each(batch_size: BATCH_SIZE) do |user|
      begin
        data = yield(user)
        ScheduledMessage.create!(
          template_id: @template_id,
          send_type: @send_type,
          content: data.dig(:jsonb),
          phone_number: data.dig(:phone_number),
          scheduled_date: data.dig(:scheduled_date)
        )
      rescue => e
        Jets.logger.info e.message
      end
    end
  end

  def get_radius(user)
    case user.preferred_distance
    when 'by_walk15'
      900
    when 'by_walk30'
      1800
    when 'by_km_3'
      3000
    when 'by_km_5'
      5000
    else
      900
    end
  end

  def get_gender_filtered_job_postings(job_postings, user)
    result_job_postings = job_postings
    if user.gender == 'male'
      result_job_postings = job_postings.where(gender: ['male', nil])
    elsif user.gender == 'female'
      result_job_postings = job_postings.where(gender: ['female', nil])
    end
    result_job_postings
  end
end
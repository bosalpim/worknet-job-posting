# frozen_string_literal: true

class Bex::FetchTreatmentByUserIdService
  include Bex
  def initialize(
    experiment_key:,
    user_id:
  )
    @experiment_key = experiment_key
    @user_id = user_id
  end

  def call
    response = HTTParty.get(endpoint)
    data = response.parsed_response.dig('data')

    treatment = TreatmentMapper.from_hash!(data)

    return treatment
  rescue StandardError => e
    Jets.logger.error e
  end

  private

  def endpoint
    [
      Bex::BASE_URL,
      'experiment',
      @experiment_key,
      'treatment',
      'user',
      @user_id
    ].join('/')
  end
end

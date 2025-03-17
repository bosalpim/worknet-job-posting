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

    begin
      TreatmentMapper.from_hash!(data)
    rescue StandardError => e
      Jets.logger.error "Treatment mapping error: #{e.message}"
      nil
    end
  rescue StandardError => e
    Jets.logger.error e
    nil
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

# frozen_string_literal: true

module Bex
  BASE_URL = Main::Application::BEX_API_URL

  module Experiment
    CAREER_CERTIFICATION = 'career_certification'
  end

  module FetchMode
    ON_DEMAND = 'onDemand'
    PRELOAD = 'preload'
  end

  class TreatmentMapper
    def self.from_hash!(hash = {})
      treatment = Treatment.new(
        experiment_status: hash.dig("status"),
        unit_id: hash.dig("unit", "id"),
        user_id: hash.dig("unit", "userId"),
        treatment_id: hash.dig("unit", "treatment", "id"),
        key: hash.dig("unit", "treatment", "key"),
        title: hash.dig("unit", "treatment", "title"),
        winner: hash.dig("unit", "treatment", "winner")
      )

      if treatment.invalid?
        raise "Treatment is invalid #{treatment.inspect}"
      end

      treatment
    end
  end

  class Treatment
    include ActiveModel::Model

    attr_accessor(
      :experiment_status,
      :unit_id,
      :user_id,
      :treatment_id,
      :key,
      :title,
      :winner
    )

    validates(
      :experiment_status,
      :unit_id,
      :user_id,
      :treatment_id,
      :key,
      :title,
      presence: true
    )

    validates :winner, inclusion: { in: [true, false] }

  end
end

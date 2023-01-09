module PublicId
  extend ActiveSupport::Concern

  included do
    public_id_length 10 # default

    validates :public_id, presence: true, uniqueness: true

    before_validation(on: :create) do
      generate_public_id
    end
  end

  module ClassMethods
    attr_reader :id_length

    private

    def public_id_length(num)
      @id_length = num
    end
  end

  def generate_public_id
    self.public_id = loop do
      pid = SecureRandom.base36(self.class.id_length)
      break pid unless self.class.exists?(public_id: pid)
    end
  end
end
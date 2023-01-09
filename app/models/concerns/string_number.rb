module StringNumber
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :string_number_fields

    def set_string_number_fields(*args)
      self.string_number_fields = *args
    end
  end

  included do
    before_validation do
      self.class.string_number_fields.each do |field|
        value = self.send(field)
        self.send("#{field}=", value.gsub(/[- ]/, '')) if value.present?
      end
    end
  end
end

module Translation
  def translate_type(model_name, object, attributes_name)
    values = object&.send(attributes_name)

    return nil if values.blank?

    if values.is_a?(Array)
      values
        .map do |value|
        I18n.t(
          "activerecord.attributes.#{model_name}.#{attributes_name}.#{value}",
          )
      end
        .join(', ')
    else
      I18n.t(
        "activerecord.attributes.#{model_name}.#{attributes_name}.#{values}",
        )
    end
  end
end

module TranslationHelper
  def translate_type(model_name, object, attributes_name, value = nil)
    values = value || object&.send(attributes_name)

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

  def translate_multiple_values(model_name, object, attribute_name)
    values = object&.send(attribute_name)

    post_word = values && values.length > 1 ? ' 등' : ''

    "#{translate_type(model_name, object, attribute_name, values&.last)}#{post_word}"
  end
end

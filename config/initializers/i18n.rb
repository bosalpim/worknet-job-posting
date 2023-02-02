I18n.load_path << Dir["#{Jets.root}/config/locales/*.yml"]
I18n.backend.load_translations
I18n.default_locale = :kr
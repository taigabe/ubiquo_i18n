require 'ubiquo_i18n'

Ubiquo::Plugin.register(:ubiquo_i18n, directory, config) do |config|
  config.add :current_locale
  config.set_default :current_locale, 'en'
end
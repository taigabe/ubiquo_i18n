begin
  require 'routing-filter'
rescue LoadError
  raise "Could not load the routing-filter gem. Install it with `gem install routing-filter` or add this line to your Gemfile: `gem 'routing-filter'`."
end

# "Touch" the Fallbacks backend module to ensure that the I18n.fallbacks method is defined.
# To use or not this backend to fallback the ymls is a decision left to the end app.
I18n::Backend::Fallbacks

require 'ubiquo_i18n'

config.after_initialize do
  Locale.current = Locale.default if Locale.table_exists?
end

Ubiquo::Plugin.register(:ubiquo_i18n, directory, config) do |config|

  config.add :locales_default_order_field, "native_name"
  config.add :locales_default_sort_order, "ASC"
  config.add :locales_access_control, lambda{
    access_control :DEFAULT => nil
  }

  config.add :last_user_locale, lambda{
    current_ubiquo_user.blank? ? nil : current_ubiquo_user.last_locale rescue nil
  }

  config.add :set_last_user_locale, lambda{ |options|
    begin
      if current_ubiquo_user.present? && current_ubiquo_user.last_locale != options[:locale]
        current_ubiquo_user.last_locale = options[:locale]
        current_ubiquo_user.save
      end
    rescue
      nil
    end
  }

  # used in the ubiquo_locale routing filter to know if should delete
  # the used params to generate or recognize the url.
  # This is useful for test environments.
  # Test environments should have all the params to generate the url properly.
  config.add :clean_url_params, lambda { !Rails.env.test? }
end

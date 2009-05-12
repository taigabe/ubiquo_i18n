require 'ubiquo_i18n'

Ubiquo::Plugin.register(:ubiquo_i18n, directory, config) do |config|
  
  config.add :locales_default_order_field, "native_name"
  config.add :locales_default_sort_order, "ASC"
  config.add :locales_access_control, lambda{
    access_control :DEFAULT => nil
  }
end

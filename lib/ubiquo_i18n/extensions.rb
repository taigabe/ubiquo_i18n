module UbiquoI18n
  module Extensions
    autoload :ActiveRecord, 'ubiquo_i18n/extensions/active_record'
    autoload :LocaleChanger, 'ubiquo_i18n/extensions/locale_changer'
    autoload :Helpers, 'ubiquo_i18n/extensions/helpers'

  end
end

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)
ActionController::Base.send(:include, UbiquoI18n::Extensions::LocaleChanger)
ActionController::Base.helper(UbiquoI18n::Extensions::Helpers)

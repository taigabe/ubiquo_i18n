module UbiquoI18n
  module Extensions
    autoload :ActiveRecord, 'ubiquo_i18n/extensions/active_record'
    autoload :AssociationProxy, 'ubiquo_i18n/extensions/association_collection'
    autoload :NamedScope, 'ubiquo_i18n/extensions/named_scope'
    autoload :Reflection, 'ubiquo_i18n/extensions/reflection'
    autoload :LocaleChanger, 'ubiquo_i18n/extensions/locale_changer'
    autoload :Helpers, 'ubiquo_i18n/extensions/helpers'
  end
end

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)
ActiveRecord::Associations::AssociationCollection.send(:include, UbiquoI18n::Extensions::AssociationCollection)
ActiveRecord::NamedScope::Scope.send(:include, UbiquoI18n::Extensions::NamedScope)
ActiveRecord::Associations::ClassMethods.send(:include, UbiquoI18n::Extensions::Associations)
Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleChanger)
Ubiquo::Extensions::Loader.append_helper(:UbiquoController, UbiquoI18n::Extensions::Helpers)
if Rails.env.test?
  ActionController::TestCase.send(:include, UbiquoI18n::Extensions::TestCase)
  ActionController::TestCase.setup(:set_session_locale)
end

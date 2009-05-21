module UbiquoI18n
  module Extensions
    autoload :ActiveRecord, 'ubiquo_i18n/extensions/active_record'
    autoload :AssociationProxy, 'ubiquo_i18n/extensions/association_collection'
    autoload :NamedScope, 'ubiquo_i18n/extensions/named_scope'
    autoload :LocaleChanger, 'ubiquo_i18n/extensions/locale_changer'
    autoload :Helpers, 'ubiquo_i18n/extensions/helpers'
  end
end

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)
ActiveRecord::Associations::AssociationCollection.send(:include, UbiquoI18n::Extensions::AssociationCollection)
ActiveRecord::NamedScope::Scope.send(:include, UbiquoI18n::Extensions::NamedScope)
ActionController::Base.send(:include, UbiquoI18n::Extensions::LocaleChanger)
ActionController::Base.helper(UbiquoI18n::Extensions::Helpers)
#ActiveRecord::NamedScope::Scope.class_eval do
#  attr_accessor :locale_scoped
#end

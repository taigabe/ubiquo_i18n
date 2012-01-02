module UbiquoI18n::Extensions; end

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)
ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::NestedAttributes)
ActiveRecord::Reflection::AssociationReflection.send(:include, UbiquoI18n::Extensions::AssociationReflection)
ActiveRecord::Associations::AssociationCollection.send(:include, UbiquoI18n::Extensions::AssociationCollection)
ActiveRecord::Associations::BelongsToAssociation.send(:include, UbiquoI18n::Extensions::BelongsToAssociation)
ActiveRecord::Associations::HasOneAssociation.send(:include, UbiquoI18n::Extensions::HasOneAssociation)
ActiveRecord::Associations::BelongsToPolymorphicAssociation.send(:include, UbiquoI18n::Extensions::BelongsToAssociation)
ActiveRecord::NamedScope::Scope.send(:include, UbiquoI18n::Extensions::NamedScope)
ActiveRecord::Associations::ClassMethods.send(:include, UbiquoI18n::Extensions::Associations)
Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleChanger)
Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleUrlBuilder)
Ubiquo::Extensions::Loader.append_helper(:UbiquoController, UbiquoI18n::Extensions::Helpers)
Ubiquo::Extensions::Loader.append_include(:ApplicationController, UbiquoI18n::Extensions::LocaleUseFallbacks::Application)
Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleUseFallbacks::Ubiquo)

ActionController::TestCase.send(:include, UbiquoI18n::Extensions::TestCase) if Rails.env.test?

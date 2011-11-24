module UbiquoI18n
  module Extensions
    module Associations

      def self.append_features(base)
        base.send :include, InstanceMethods
        base.alias_method_chain :collection_accessor_methods, :shared_translations
        base.alias_method_chain :association_accessor_methods, :shared_translations
        base.alias_method_chain :delete_all_has_many_dependencies, :shared_translations
        base.alias_method_chain :nullify_has_many_dependencies, :shared_translations
      end

      module InstanceMethods
        def collection_accessor_methods_with_shared_translations(reflection, association_proxy_class, writer = true)
          collection_accessor_methods_without_shared_translations(reflection, association_proxy_class, writer)
          process_translation_shared reflection
        end

        def association_accessor_methods_with_shared_translations(reflection, association_proxy_class)
          association_accessor_methods_without_shared_translations(reflection, association_proxy_class)
          process_translation_shared reflection
        end

        def delete_all_has_many_dependencies_with_shared_translations(record, reflection_name, association_class, dependent_conditions)
          reflections[reflection_name].propagate_dependent_option_with_shared_translations(record) do
            delete_all_has_many_dependencies_without_shared_translations(record, reflection_name, association_class, dependent_conditions)
          end
        end

        def nullify_has_many_dependencies_with_shared_translations(record, reflection_name, association_class, primary_key_name, dependent_conditions)
          reflections[reflection_name].propagate_dependent_option_with_shared_translations(record) do
            nullify_has_many_dependencies_without_shared_translations(record, reflection_name, association_class, primary_key_name, dependent_conditions)
          end
        end
      end
    end
  end
end
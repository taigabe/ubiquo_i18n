module UbiquoI18n
  module Extensions

    # This module extends the has_one assignation to do the expected job with shared translations.
    # Rails has a custom replace method for has_one that won't trigger our
    # automatic propagation. Also, usually the save is done at the same assignation
    # moment, so we can't do our job there.
    # The solution is to manually propagate the assignation we're doing to the
    # translations of the record.
    module HasOneAssociation

      def self.append_features(base)
        base.send :include, InstanceMethods
        base.alias_method_chain :replace, :shared_translations
      end

      module InstanceMethods
        def replace_with_shared_translations(obj, dont_save = false)
          if proxy_reflection.is_translation_shared?
            proxy_owner.class.translating_relations do
              proxy_owner.translations.each do |translation|
                association = translation.send("#{@reflection.name}_without_shared_translations")
                association.replace(obj, dont_save) unless association.nil?
              end
            end
          end
          replace_without_shared_translations(obj, dont_save)
        end
      end
    end
  end
end
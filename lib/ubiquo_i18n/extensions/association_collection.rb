module UbiquoI18n
  module Extensions
    module AssociationCollection
   
      def self.included(klass)
        klass.alias_method_chain :add_record_to_target_with_callbacks, :translatable
      end
      
      # This method intercepts an add_record_to_target_with_callbacks call, because
      # it's the "common point" when we'll always go when updating a relationship.
      # 
      # If a relation is marked as shared (:translatable => false), then any change 
      # in a translation must update the other translations
      def add_record_to_target_with_callbacks_with_translatable(record, &block)
        if @reflection.options[:translatable] == false && !@owner.class.instance_variable_get('@is_translating_relations')
          # This flag is used to prevent cyclical chain updates
          @owner.class.instance_variable_set('@is_translating_relations', true)
          
          begin
            add_record_to_target_with_callbacks_without_translatable record, &block
            relationship_contents = load_target
            # Update the translations with the new relationship contents
            @owner.translations.each do |translation|
              translation_relationship_contents = []
              relationship_contents.each do |old_rel|
                # if the linked object is translatable, find an instance with the proper locale to do the link
                if old_rel.class.instance_variable_get('@translatable')
                  existing_translation = old_rel.translations.first(:conditions => {:locale => self.locale})

                  # Find or create a translation and add it to the relationship_contents
                  unless existing_translation || old_rel.being_translated?
                    # create a new translation since there isn't one with this locale
                    translated_rel = old_rel.translate(translation.locale)
                    translation_relationship_contents << translated_rel
                    translated_rel.save
                  else
                    translation_relationship_contents << existing_translation
                  end

                else
                  # Not translatable - we just clone the object because every
                  # translation should have an independent instance
                  translated_rel = old_rel.clone
                  translation_relationship_contents << translated_rel
                  translated_rel.save                    
                end
              end
              translation.send(@reflection.name.to_s + '=', translation_relationship_contents)
            end
          rescue
            @owner.class.instance_variable_set('@is_translating_relations', false)
            raise
          end
          @owner.class.instance_variable_set('@is_translating_relations', false)
        else
          add_record_to_target_with_callbacks_without_translatable record, &block
        end
      end
    end
  end
end

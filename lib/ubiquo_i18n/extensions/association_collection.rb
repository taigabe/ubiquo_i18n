module UbiquoI18n
  module Extensions
    module AssociationCollection
   
      def self.included(klass)
        klass.alias_method_chain :add_record_to_target_with_callbacks, :translatable
      end
      
      def add_record_to_target_with_callbacks_with_translatable(record, &block)
        if @reflection.options[:translatable] == false && !@owner.class.instance_variable_get('@is_translating_relations')
          @owner.class.instance_variable_set('@is_translating_relations', true)
          
          begin
            add_record_to_target_with_callbacks_without_translatable record, &block
            relationship_contents = load_target
            @owner.translations.each do |translation|
              translation_relationship_contents = []
                relationship_contents.each do |old_rel|
                  if old_rel.class.instance_variable_get('@translatable')
                    existing_translation = old_rel.translations.first(:conditions => {:locale => self.locale})

                    unless existing_translation || old_rel.being_translated?
                      translated_rel = old_rel.translate(translation.locale)
                      translation_relationship_contents << translated_rel
                      translated_rel.save
                    else
                      translation_relationship_contents << existing_translation
                    end

                else
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

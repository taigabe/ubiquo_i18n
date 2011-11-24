module UbiquoI18n
  module Extensions

    # This module adds support for nested_attributes in translation-shared associations,
    # with a behaviour that is the usual one to do, and thus avoiding the need
    # to implement it in the application.
    # In nested_attributes, given that is a feature with a very typical use case,
    # we make the assumption that, in the moment of the assignation, Locale.current
    # dictates if we are translating an existing instance or really updating an existing one.
    # This way in the application in most of cases nothing needs to be done, neither
    # in the view, controller, nor model.
    module NestedAttributes

      def self.append_features(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
        base.singleton_class.send :alias_method_chain, :accepts_nested_attributes_for, :shared_translations
      end

      module ClassMethods
        def accepts_nested_attributes_for_with_shared_translations(*attr_names)
          accepts_nested_attributes_for_without_shared_translations(*attr_names)
          # aliase the newly created setter with our new behaviour
          attr_names.each do |association_name|
            if (reflection = reflect_on_association(association_name))
              define_method "#{association_name}_attributes_with_shared_translations=" do |attribute_collection|
                attribute_set = normalized_attributes_for_nested_assignation(attribute_collection)

                if reflection.options[:translation_shared]
                  # When we set attributes to an existing object, check whether it is
                  # in the current locale. If not, create a new association to set
                  # there the attributes

                  # Use the current set of relations to avoid querying each one
                  # in the DB.
                  # If the object is new, maybe we still don't have the correct content_id
                  current_relations = new_record? ? nil : send(association_name)
                  attribute_set.each do |attributes|
                    # only need to act for existing asset relations that we are updating
                    if (attributes['id'] || attributes[:id]) && !attributes['_destroy']
                      id_field = attributes['id'] ? 'id' : :id
                      existing_relation = find_existing_relation(attributes[id_field], reflection, current_relations)
                      if existing_relation && existing_relation.locale != Locale.current
                        # setting this, the translation will be automatically created
                        attributes[id_field] = nil
                        attributes['content_id'] = existing_relation.content_id
                      end
                    end
                  end
                end
                send("#{association_name}_attributes_without_shared_translations=", attribute_set)
              end
              alias_method_chain "#{association_name}_attributes=", :shared_translations
            end
          end
        end
      end

      module InstanceMethods
        # Given an id, returns the relation that corresponds to it.
        # If given, uses +set+ to avoid DB queries
        def find_existing_relation(id, reflection, set = nil)
          set ? set.select{|ar| ar.id == id.to_i}.first : reflection.klass.find(id)
        end

        # nested_attributes accepts either a hash or an array and then converts
        # the input to an array to do its transformations. We need to do this step
        # before, to apply our own behaviour
        def normalized_attributes_for_nested_assignation attributes_collection
          unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
            raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
          end

          if attributes_collection.is_a?(Hash)
            # this is to fit assign_nested_attributes_for_collection_association
            attributes_collection.sort_by { |index, _| index.to_i }.map { |_, attributes| attributes }
          else
            # already an array
            attributes_collection
          end
        end
      end
    end
  end
end
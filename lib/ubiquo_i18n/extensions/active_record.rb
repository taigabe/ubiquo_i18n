module UbiquoI18n
  module Extensions
    module ActiveRecord
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Class method for ActiveRecord that states which attributes are translatable and therefore when updated will be only updated for the current locale.
        #
        # EXAMPLE:
        #
        #   translatable :title, :description

        def translatable(*attrs)
          # inherit translatable attributes
          @translatable_attributes = self.superclass.instance_variable_get('@translatable_attributes') || [] 
          # add attrs from this class
          @translatable_attributes += attrs
        end
      end

    end
  end
end

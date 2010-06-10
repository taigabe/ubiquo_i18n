module UbiquoI18n
  module Extensions
    module AssociationCollection
   
      def self.included(klass)
        klass.alias_method_chain :count, :translation_shared
      end
      
      def count_with_translation_shared
        loaded? ? size : count_without_translation_shared
      end
    end
  end
end

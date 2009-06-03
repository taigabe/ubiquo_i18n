module UbiquoI18n
  module Adapters
    # Extends the create_table method to support the :translatable option
    module SchemaStatements
      
      # Perform the actual linking with create_table
      def self.included(klass)
        klass.send(:alias_method_chain, :create_table, :translatable)
      end
      
      # Parse the :translatable option as a create_table extension
      # This will currently add two fields:
      #   table.locale: string
      #   table.content_id sequence
      # with their respective indexes
      def create_table_with_translatable(table_name, options={})
        translatable = options.delete(:translatable)
        create_table_without_translatable(table_name, options) do |table_definition|
          yield table_definition
          if translatable
            table_definition.string :locale, :nil => false
            table_definition.sequence table_name, :content_id 
          end
        end
        if translatable
          add_index table_name, :locale
          add_index table_name, :content_id unless indexes(table_name).map(&:columns).flatten.include? "content_id"
        end
      end
    end
  end
end

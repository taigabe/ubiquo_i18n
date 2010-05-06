module UbiquoI18n
  module Adapters
    # Extends the create_table method to support the :translatable option
    module SchemaStatements

      # Perform the actual linking with create_table
      def self.included(klass)
        klass.send(:alias_method_chain, :create_table, :translatable)
        klass.send(:alias_method_chain, :change_table, :translatable)
      end

      # Parse the :translatable option as a create_table extension
      # This will currently add two fields:
      #   table.locale: string
      #   table.content_id sequence
      # with their respective indexes
      def create_table_with_translatable(*args, &block)
        SchemaStatements.apply_translatable_option!(:create_table, self, *args, &block)
      end

      # Parse the :translatable option as a change_table extension
      # This will currently add two fields:
      #   table.locale: string
      #   table.content_id sequence
      # with their respective indexes
      def change_table_with_translatable(*args, &block)
        SchemaStatements.apply_translatable_option!(:change_table, self, *args, &block)
      end

      # Performs the actual job of applying the :translatable option
      def self.apply_translatable_option!(method, adapter, table_name, options = {})
        translatable = options.delete(:translatable)
        method_name = "#{method}_without_translatable"

        # not all methods accept the options hash
        args = [table_name]
        args << options if adapter.method(method_name).arity != 1

        adapter.send(method_name, *args) do |table|
          if translatable
            table.string :locale, :nil => false
            table.sequence table_name, :content_id
          elsif translatable == false && method == :change_table
            table.remove :locale
            table.remove_sequence :test, :content_id
          end
          yield table
        end

        # create or remove indexes for these new fields
        indexes = [:locale, :content_id]
        if translatable
          indexes.each do |index|
            unless adapter.indexes(table_name).map(&:columns).flatten.include? index.to_s
              adapter.add_index table_name, index
            end
          end
        elsif translatable == false
          indexes.each do |index|
            if adapter.indexes(table_name).map(&:columns).flatten.include? index.to_s
              adapter.remove_index table_name, index
            end
          end
        end
      end

    end
  end
end

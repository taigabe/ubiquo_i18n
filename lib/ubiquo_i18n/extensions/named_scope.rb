module UbiquoI18n
  module Extensions
    module NamedScope

      def self.included(klass)
        klass.alias_method_chain :method_missing, :locale_scope
      end

      # This method is executed when a named scope is being resolved. It will
      # check if this scope is the locale() scope, and if so, will set all
      # the necessary for the actual locale filter be applied
      def method_missing_with_locale_scope(method, *args, &block)
        if proxy_options[:locale_list]
          # this is a locale() call
          # find the model we are acting on
          klass = proxy_scope.model_name.constantize.really_translatable_class
          # tell the model that we are heading there and merge the asked locale list
          current_locale_list = klass.instance_variable_get(:@current_locale_list) || []
          unless already_locale_filtered current_locale_list
            klass.instance_variable_set(
              :@current_locale_list,
              current_locale_list << proxy_options[:locale_list]
            )
          end
        end
        method_missing_without_locale_scope(method, *args, &block)
      end

      # Due to be in method_missing, some code in named_scope.rb can lead to
      # reenter in the application of the locale filter. Here we discriminate
      # if this is one of these cases.
      def already_locale_filtered(current_filters)
        current_filters.map(&:object_id).include? proxy_options[:locale_list].object_id
      end
    end
  end
end

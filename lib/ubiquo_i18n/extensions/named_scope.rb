module UbiquoI18n
  module Extensions
    module NamedScope
   
      def self.included(klass)
        klass.alias_method_chain :method_missing, :locale_scope
      end
      
      def method_missing_with_locale_scope(method, *args, &block)
        if proxy_options[:locale_scoped] && proxy_options[:locale_list]
          # this is a locale() call
          begin
            # find the model we are acting on
            klass = proxy_scope
            while !klass.is_a?(Class)
              if klass.respond_to?(:proxy_scope)
                klass = klass.proxy_scope
              elsif klass.is_a?(Array)
                klass = klass.first.class
              end
            end
            # tell the model that we are heading there
            if klass.respond_to?(:really_translatable_class)
              good_klass = klass.really_translatable_class
              good_klass.instance_variable_set('@locale_scoped', true)
              current_locale_list = good_klass.instance_variable_get('@current_locale_list')
              current_locale_list ||= []
              current_locale_list += proxy_options[:locale_list]
              good_klass.instance_variable_set('@current_locale_list', current_locale_list)
            end
          end
          # clear these flag options
          @proxy_options = {}
        end
        method_missing_without_locale_scope(method, *args, &block)
      end
    end
  end
end

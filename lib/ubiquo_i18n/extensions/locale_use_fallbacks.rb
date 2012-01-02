module UbiquoI18n
  module Extensions
    module LocaleUseFallbacks

      # Sets the default use_fallbacks behaviour for all the application controllers
      module Application
        def self.included(klass)
          klass.class_eval do
            before_filter :use_locale_fallbacks

            def use_locale_fallbacks
              Locale.use_fallbacks = false
            end
          end
        end
      end

      # Sets the default use_fallbacks behaviour for all the ubiquo controllers
      module Ubiquo
        def self.included(klass)
          klass.class_eval do
            def use_locale_fallbacks
              Locale.use_fallbacks = true
            end
          end
        end
      end

    end
  end
end

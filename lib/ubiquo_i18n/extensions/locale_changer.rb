module UbiquoI18n
  module Extensions
    module LocaleChanger
      def self.included(klass)
        klass.send :include, InstanceMethods
        klass.send :helper_method, :current_locale
        klass.send :before_filter, :load_locale
      end

      module InstanceMethods
        # Load the locale from the params or user or get the default
        def load_locale
          if @current_locale.blank?
            Locale.current = @current_locale = find_locale
            ubiquo_config_call(:set_last_user_locale, { :context => :ubiquo_i18n,
                                                        :locale  => @current_locale })
          end

          @current_locale
        end

        # The locale is assigned through the load_locale filter.
        # If not, this method its probably called from a test, so the locale
        # will not be setted in the instance variable,
        # only will be found and returned
        def current_locale
          @current_locale || find_locale
        end

        def find_locale
          find_locale_in_params or find_locale_in_user or Locale.default
        end

        def find_locale_in_params
          params[:locale]
        rescue
          nil
        end

        def find_locale_in_user
          ubiquo_config_call(:last_user_locale, { :context => :ubiquo_i18n })
        rescue
          nil
        end
      end
    end
  end
end

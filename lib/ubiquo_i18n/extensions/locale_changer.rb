module UbiquoI18n
  module Extensions
    module LocaleChanger
      def self.included(klass)
        klass.send :include, InstanceMethods
        klass.send :helper_method, :current_locale
        klass.send :before_filter, :current_locale
      end
      
      module InstanceMethods
        # Returns the current locale, and sets it in the session if it wasn't there
        def current_locale
          @current_locale ||= params[:locale] || session[:locale] || Locale.default
          Locale.current = session[:locale] = @current_locale
        end
      end
    end
  end
end

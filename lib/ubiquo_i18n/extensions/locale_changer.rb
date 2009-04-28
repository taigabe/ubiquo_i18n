module UbiquoI18n
  module Extensions
    module LocaleChanger
      def self.included(klass)
        klass.send :include, InstanceMethods
        klass.send :helper_method, :current_locale
      end
      
      module InstanceMethods
        def current_locale
          @current_locale ||= params[:locale] || session[:locale]
          session[:locale] = @current_locale
        end
      end
    end
  end
end

module UbiquoI18n
  module Extensions
    module LocaleChanger
      def self.included(klass)
        klass.send :include, InstanceMethods
        klass.before_filter :check_new_locale
      end
      
      module InstanceMethods
        def check_new_locale
          new_locale = params[:locale] || session[:locale]
          Locale.current = new_locale if new_locale
          session[:locale] = Locale.current
        end
        
      end
    end
  end
end

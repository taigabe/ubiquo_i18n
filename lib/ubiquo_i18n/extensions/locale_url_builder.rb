module UbiquoI18n
  module Extensions
    module LocaleUrlBuilder
      def self.included(klass)
        klass.send :include, InstanceMethods
      end

      module InstanceMethods
        # sets the current locale as a parameter in the url.
        # the locale option for the url has preference over the current locale.
        def default_url_options(options = {})
          { :locale => current_locale.to_s }.merge(options)
        end
      end
    end
  end
end

module UbiquoI18n
  module Extensions
    module TestCase
      def self.included(base)
        base.send :include, InstanceMethods
        base.send :alias_method_chain, :process, :locale
      end

      module InstanceMethods
        # set the locale parameter in the functional test method process
        # to avoid errors related to the tests and no the app
        def process_with_locale(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
          parameters = { :locale => ::Locale.default }.merge(parameters || {})
          process_without_locale(action, parameters, session, flash, http_method)
        end
      end
    end
  end
end

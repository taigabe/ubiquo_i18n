module UbiquoI18n
  module Extensions
    module FilterHelpers
      class LocaleFilter < Ubiquo::Extensions::FilterHelpers::LinkFilter

        def configure(options={})
          defaults = {
            :field       => :filter_locale,
            :collection  => Locale.active,
            :id_field    => :iso_code,
            :name_field  => :native_name,
            :caption     => I18n.t('ubiquo.language')
          }
          @options = defaults.merge(options)
        end

      end
    end
  end
end

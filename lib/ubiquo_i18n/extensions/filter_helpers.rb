require 'ubiquo_i18n/extensions/filter_helpers/locale_filter'

module UbiquoI18n
  module Extensions
    module FilterHelpers
    end
  end
end

Ubiquo::Extensions::FilterHelpers.send(:include, UbiquoI18n::Extensions::FilterHelpers)

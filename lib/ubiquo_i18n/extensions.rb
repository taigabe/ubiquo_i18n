module UbiquoI18n
  module Extensions
    autoload :ActiveRecord, 'ubiquo_i18n/extensions/active_record'
  end
end

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)

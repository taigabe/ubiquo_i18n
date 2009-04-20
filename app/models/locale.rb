class Locale < ActiveRecord::Base
  validates_presence_of :iso_code
  validates_uniqueness_of :iso_code
  
  # Return the current working locale
  def self.current
    Ubiquo::Config.context(:ubiquo_i18n).get(:current_locale)
  end
end
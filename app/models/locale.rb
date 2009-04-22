class Locale < ActiveRecord::Base
  validates_presence_of :iso_code
  validates_uniqueness_of :iso_code
  
  # Return the current working locale
  def self.current
    @current_locale ||= Ubiquo::Config.context(:ubiquo_i18n).get(:current_locale)
  end
  def self.current=(locale)
    @current_locale = locale
  end
  
  def self.using_locale(locale, &block)
    old_locale, @current_locale = @current_locale, locale
    block.call
    @current_locale = old_locale
  end
end

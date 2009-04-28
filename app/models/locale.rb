class Locale < ActiveRecord::Base
  validates_presence_of :iso_code
  validates_uniqueness_of :iso_code
  
  named_scope :active, {:conditions => {:is_active => true}}
  
  def self.using_locale(locale, &block)
    old_locale, @current_locale = @current_locale, locale
    block.call
    @current_locale = old_locale
  end
end

class Locale < ActiveRecord::Base
  validates_presence_of :iso_code
  validates_uniqueness_of :iso_code
  
  named_scope :active, {:conditions => {:is_active => true}}
  named_scope :ordered, {:order => 'iso_code ASC'}
  
  #there are only one default locale, but named scopes don't support find single items
  named_scope :defaults, {:conditions => {:is_default => true}}
  
  def self.using_locale(locale, &block)
    old_locale, @current_locale = @current_locale, locale
    block.call
    @current_locale = old_locale
  end
  
  def self.default(reload = false)
    @default = (!reload && @default) || defaults.first.try(:iso_code)
  end   
end

class Locale < ActiveRecord::Base
  validates_presence_of :iso_code
  validates_uniqueness_of :iso_code, :case_sensitive => false

  named_scope :active, {:conditions => {:is_active => true}}
  named_scope :ordered, {:order => 'iso_code ASC'}
  named_scope :ordered_alphabetically, {:order => 'native_name ASC'}

  #there are only one default locale, but named scopes don't support find single items
  named_scope :defaults, {:conditions => {:is_default => true}}

  # Stores the current locale of the application
  cattr_accessor :current

  # Cache locale instances by iso_code
  cattr_accessor :cached_locales

  def self.default
    defaults.first.try(:iso_code)
  end

  def to_s
    iso_code
  end

  def humanized_name
    native_name.capitalize
  end

  # Method overwritten due to its extensive use. Now caching results
  def self.find_by_iso_code code
    unless self.cached_locales
      self.cached_locales = {}
      active.each do |locale|
        cached_locales[locale.iso_code] = locale
      end
    end
    self.cached_locales[code]
  end

end

class Locale < ActiveRecord::Base
  validates_presence_of :iso_code
  validates_uniqueness_of :iso_code
end
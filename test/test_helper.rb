require File.dirname(__FILE__) + "/../../../../test/test_helper.rb"

def create_locale(options = {})
  default_options = {
    :iso_code => 'ca'
  }
  Locale.create(default_options.merge(options))
end

case conn = ActiveRecord::Base.connection
when ActiveRecord::ConnectionAdapters::AbstractAdapter
  conn.client_min_messages = "ERROR"
end

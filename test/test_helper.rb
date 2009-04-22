require File.dirname(__FILE__) + "/../../../../test/test_helper.rb"

def create_locale(options = {})
  default_options = {
    :iso_code => 'ca'
  }
  Locale.create(default_options.merge(options))
end

def create_model(options = {})
  TestModel.create(options)
end

TestModel = Class.new(ActiveRecord::Base)

def create_test_model_backend
  # Creates a test table for AR things work properly
  if ActiveRecord::Base.connection.tables.include?("test_models")
    ActiveRecord::Base.connection.drop_table :test_models
  end
  ActiveRecord::Base.connection.create_table :test_models, :translatable => true do |t|
    t.string :field1
    t.string :field2
  end
  # Model used to test extensions
  TestModel.class_eval do
    translatable :field1
  end
end

case conn = ActiveRecord::Base.connection
when ActiveRecord::ConnectionAdapters::AbstractAdapter
  conn.client_min_messages = "ERROR"
end

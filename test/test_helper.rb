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

def create_related_model(options = {})
  RelatedTestModel.create(options)
end

TestModel = Class.new(ActiveRecord::Base) unless Object.const_defined? 'TestModel'
RelatedTestModel = Class.new(ActiveRecord::Base) unless Object.const_defined? 'RelatedTestModel'

def create_test_model_backend
  # Creates a test table for AR things work properly
  if ActiveRecord::Base.connection.tables.include?("test_models")
    ActiveRecord::Base.connection.drop_table :test_models
  end
  if ActiveRecord::Base.connection.tables.include?("related_test_models")
    ActiveRecord::Base.connection.drop_table :related_test_models
  end
  ActiveRecord::Base.connection.create_table :test_models, :translatable => true do |t|
    t.string :field1
    t.string :field2
  end
  ActiveRecord::Base.connection.create_table :related_test_models do |t|
    t.integer :test_model_id
    t.string :field1
  end
  # Model used to test extensions
  TestModel.class_eval do
    translatable :field1
    has_many :related_test_models
  end
  
  RelatedTestModel.class_eval do
    belongs_to :test_model
  end
end

case conn = ActiveRecord::Base.connection
when ActiveRecord::ConnectionAdapters::AbstractAdapter
  conn.client_min_messages = "ERROR"
end

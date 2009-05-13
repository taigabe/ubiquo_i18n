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

def create_translatable_related_model(options = {})
  TranslatableRelatedTestModel.create(options)
end

%w{TestModel RelatedTestModel UnsharedRelatedTestModel TranslatableRelatedTestModel ChainTestModelA ChainTestModelB ChainTestModelC}.each do |c|
  Object.const_set(c, Class.new(ActiveRecord::Base)) unless Object.const_defined? c
end

def create_test_model_backend
  # Creates a test table for AR things work properly
  %w{test_models related_test_models unshared_related_test_models translatable_related_test_models chain_test_model_as chain_test_model_bs chain_test_model_cs}.each do |table|
    if ActiveRecord::Base.connection.tables.include?(table)
      ActiveRecord::Base.connection.drop_table table
    end
  end
  ActiveRecord::Base.connection.create_table :test_models, :translatable => true do |t|
    t.string :field1
    t.string :field2
  end
  ActiveRecord::Base.connection.create_table :related_test_models do |t|
    t.integer :test_model_id
    t.string :field1
  end
  ActiveRecord::Base.connection.create_table :unshared_related_test_models do |t|
    t.integer :test_model_id
    t.string :field1
  end
  ActiveRecord::Base.connection.create_table :translatable_related_test_models, :translatable => true do |t|
    t.integer :test_model_id
    t.string :field
    t.string :common
  end
  ActiveRecord::Base.connection.create_table :chain_test_model_as, :translatable => true do |t|
    t.integer :chain_test_model_b_id
    t.string :field
  end
  ActiveRecord::Base.connection.create_table :chain_test_model_bs, :translatable => true do |t|
    t.integer :chain_test_model_c_id
    t.string :field
  end
  ActiveRecord::Base.connection.create_table :chain_test_model_cs, :translatable => true do |t|
    t.integer :chain_test_model_a_id
    t.string :field
  end
  
  
  # Models used to test extensions
  TestModel.class_eval do
    translatable :field1#, :shared_relations => [:shared_related_test_models, :translatable_related_test_models]
    has_many :related_test_models
    has_many :unshared_related_test_models
    has_many :shared_related_test_models, :class_name => "RelatedTestModel", :translatable => false
    has_many :translatable_related_test_models, :translatable => false
  end
  
  RelatedTestModel.class_eval do
    belongs_to :test_model
  end

  UnsharedRelatedTestModel.class_eval do
    belongs_to :test_model
  end

  TranslatableRelatedTestModel.class_eval do
    translatable :field
    belongs_to :test_model
    has_many :related_test_models
  end
  
  ChainTestModelA.class_eval do
    translatable :field#, :shared_relations => :chain_test_model_cs
    belongs_to :chain_test_model_b
    has_many :chain_test_model_cs, :translatable => false
  end
  ChainTestModelB.class_eval do
    translatable :field#, :shared_relations => :chain_test_model_as
    belongs_to :chain_test_model_c
    has_many :chain_test_model_as, :translatable => false
  end
  ChainTestModelC.class_eval do
    translatable :field, :shared_relations => :chain_test_model_bs
    belongs_to :chain_test_model_a
    has_many :chain_test_model_bs, :translatable => false
  end
end

case conn = ActiveRecord::Base.connection
when ActiveRecord::ConnectionAdapters::AbstractAdapter
  conn.client_min_messages = "ERROR"
end

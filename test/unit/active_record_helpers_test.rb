require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::ActiveRecordHelpersTest < ActiveSupport::TestCase

  
  def test_simple_filter
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    assert_equal 1, TestModel.locale('es').size
    assert_equal 'es', TestModel.locale('es').first.locale
  end
  
  def test_many_contents
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 2, :locale => 'es')
    assert_equal 2, TestModel.locale('es').size
    assert_equal %w{es es}, TestModel.locale('es').map(&:locale)
  end
  
  def test_many_locales_many_contents
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    
    assert_equal 2, TestModel.locale('es').size
    assert_equal 1, TestModel.locale('ca').size
    assert_equal 2, TestModel.locale('ca', 'es').size
    assert_equal %w{ca es}, TestModel.locale('ca', 'es').map(&:locale)
  end
  
  def test_search_all_locales_sorted
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')
    
    assert_equal %w{ca es}, TestModel.locale('ca', :ALL).map(&:locale)
    assert_equal %w{es en}, TestModel.locale('en', :ALL).map(&:locale)
    assert_equal %w{es es}, TestModel.locale('es', :ALL).map(&:locale)
    assert_equal %w{ca en}, TestModel.locale('ca', 'en', :ALL).map(&:locale)
    
    # :ALL position is indifferent
    assert_equal %w{es en}, TestModel.locale(:ALL, 'en').map(&:locale)
  end
  
  def test_search_by_content
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')
    
    assert_equal %w{es ca}, TestModel.content(1).map(&:locale)
    assert_equal %w{es ca es en}, TestModel.content(1, 2).map(&:locale)
  end
  
  def test_search_by_content_and_locale
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')
    
    assert_equal %w{es}, TestModel.locale('es').content(1).map(&:locale)
    assert_equal %w{ca en}, TestModel.content(1, 2).locale('ca', 'en').map(&:locale)
    assert_equal %w{ca es}, TestModel.content(1, 2).locale('ca', 'es').map(&:locale)
    assert_equal %w{}, TestModel.content(1).locale('en').map(&:locale)
  end
  
  private
      
  def create_model(options = {})
    TestModel.create(options)
  end
end

# Creates a test table for AR things work properly
if ActiveRecord::Base.connection.tables.include?("test_models")
  ActiveRecord::Base.connection.drop_table :test_models
end
ActiveRecord::Base.connection.create_table :test_models, :translatable => true do
end
# Model used to test Versionable extensions
TestModel = Class.new(ActiveRecord::Base)

TestModel.class_eval do
  translatable
end

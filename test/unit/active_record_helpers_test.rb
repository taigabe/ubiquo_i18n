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
  
  def test_search_with_chained_locale_call
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 2, :locale => 'ca')
    create_model(:content_id => 3, :locale => 'en')
    
    assert_equal %w{ca}, TestModel.locale('en','es', :ALL).locale('es','ca').locale('ca').map(&:locale)
  end

  
  def test_search_by_content
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')
    
    assert_equal %w{es ca}, TestModel.content(1).all(:order => "id").map(&:locale)
    assert_equal %w{es ca es en}, TestModel.content(1, 2).map(&:locale)
  end
  
  def test_search_by_content_and_locale
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')
    
    assert_equal %w{es}, TestModel.locale('es').content(1).map(&:locale)
    assert_equal_set %w{ca en}, TestModel.content(1, 2).locale('ca', 'en').map(&:locale)
    assert_equal_set %w{ca es}, TestModel.content(1, 2).locale('ca', 'es').map(&:locale)
    assert_equal %w{}, TestModel.content(1).locale('en').map(&:locale)
  end
  
  def test_search_by_locale_with_translatable_different_values
    create_model(:content_id => 1, :field1 => '1', :locale => 'es')
    create_model(:content_id => 1, :field1 => '2', :locale => 'en')
    
    assert_equal %w{}, TestModel.locale('es').all(:conditions => {:field1 => '2'}).map(&:locale)
    assert_equal %w{en}, TestModel.locale('es', :ALL).all(:conditions => {:field1 => '2'}).map(&:locale)
  end
  
  def test_search_by_locale_with_include
    model = create_model
    create_related_model(:test_model => model, :field1 => '1')
    create_related_model(:test_model => model, :field1 => '2')
    
    assert_equal [model], TestModel.all(:conditions => "related_test_models.field1 = '1'", :include => :related_test_models)
    assert_equal [], TestModel.locale('es', :ALL).all(:conditions => "related_test_models.field1 = '10'", :include => :related_test_models)
    assert_equal [model], TestModel.locale('es', :ALL).all(:conditions => "related_test_models.field1 = '1'", :include => :related_test_models)
  end
  
  def test_search_by_locale_with_joins
    model = create_model
    create_related_model(:test_model => model, :field1 => '1')
    create_related_model(:test_model => model, :field1 => '2')
    
    assert_equal [model], TestModel.all(:conditions => "related_test_models.field1 = '1'", :joins => :related_test_models)
    assert_equal [], TestModel.locale('es', :ALL).all(:conditions => "related_test_models.field1 = '10'", :joins => :related_test_models)
    assert_equal [model], TestModel.locale('es', :ALL).all(:conditions => "related_test_models.field1 = '1'", :joins => :related_test_models)
  end
  
  def test_search_by_locale_with_limit
    20.times do 
      create_model(:locale => 'ca', :field1 => '1')
    end
    20.times do 
      create_model(:locale => 'en', :field1 => '2')
    end
    
    assert_equal 40, TestModel.locale('es', :ALL).count
    assert_equal 10, TestModel.locale('es', :ALL).all(:conditions => "field1 = '1'", :limit => 10).size
    assert_equal 5, TestModel.locale('en', :ALL).all(:conditions => "field1 = '1'", :limit => 5).size
  end
  
  def test_search_by_locale_with_group_by
    10.times do 
      create_model(:locale => 'ca', :field1 => '1')
    end
    20.times do 
      create_model(:locale => 'en', :field1 => '2')
    end
    
    assert_equal_set ["10", "20"], TestModel.locale('es', :ALL).all(:select => 'COUNT(*) as numvalues', :group => :field1).map(&:numvalues)
  end
  
  def test_search_by_locale_without_explicit_find
    model = create_model(:locale => 'ca', :field1 => '1')
    locale_evaled = TestModel.locale('es')
    no_evaled = TestModel.all 
    assert_equal [], locale_evaled
    assert_equal [model], no_evaled
  end
  
  def test_search_by_locale_with_special_any_locale
    model = create_model(:locale => 'any', :field1 => '1')
    assert_equal [model], TestModel.locale('es')
    assert_equal 1, TestModel.locale('es').count
    assert_equal [model], TestModel.locale(:ALL)
    assert_equal 1, TestModel.locale(:ALL).count
  end
  
  def test_search_by_locale_should_work_with_symbols
    model = create_model(:locale => 'es', :field1 => '1')
    assert_equal [model], TestModel.locale(:es)    
    assert_equal 1, TestModel.locale(:es).count
  end

  def test_search_translations
    es_m1 = create_model(:content_id => 1, :locale => 'es')
    ca_m1 = create_model(:content_id => 1, :locale => 'ca')
    de_m1 = create_model(:content_id => 1, :locale => 'de')
    es_m2 = create_model(:content_id => 2, :locale => 'es')
    en_m2 = create_model(:content_id => 2, :locale => 'en')
    en_m3 = create_model(:content_id => 3, :locale => 'en')
    
    assert_equal_set [es_m1, de_m1], ca_m1.translations
    assert_equal_set [ca_m1, de_m1], es_m1.translations
    assert_equal_set [en_m2], es_m2.translations
    assert_equal [], en_m3.translations
  end
  
  def test_translations_uses_named_scope
    # this is what is tested
    TestModel.expects(:translations)
    # since we mock translations, the following needs to be mocked too (called on creation)
    TestModel.any_instance.expects(:update_translations)
    create_model(:content_id => 1, :locale => 'es').translations
  end
  
  def test_translations_finds_using_single_translatable_scope
    TestModel.class_eval do
      add_translatable_scope lambda{|el| "test_models.field1 = '#{el.field1}'"}
    end
    
    es_1a = create_model(:content_id => 1, :locale => 'es', :field1 => 'a')
    en_1b = create_model(:content_id => 1, :locale => 'en', :field1 => 'b')
    es_2a = create_model(:content_id => 2, :locale => 'es', :field1 => 'a')
    en_2a = create_model(:content_id => 2, :locale => 'en', :field1 => 'a')
    
    assert_equal_set [], es_1a.translations
    assert_equal_set [], en_1b.translations
    assert_equal_set [en_2a], es_2a.translations
    # restore
    TestModel.instance_variable_set('@translatable_scopes', [])
  end
      
  def test_translations_finds_using_multiple_translatable_scopes
    TestModel.class_eval do
      add_translatable_scope lambda{|el| "test_models.field1 = '#{el.field1}'"}
      add_translatable_scope lambda{|el| "test_models.field2 = '#{el.field2}'"}
    end
    
    es_1a = create_model(:content_id => 1, :locale => 'es', :field1 => 'a', :field2 => 'a')
    en_1b = create_model(:content_id => 1, :locale => 'en', :field1 => 'b', :field2 => 'a')
    es_2a = create_model(:content_id => 2, :locale => 'es', :field1 => 'a', :field2 => 'a')
    en_2a = create_model(:content_id => 2, :locale => 'en', :field1 => 'a', :field2 => 'a')
    ca_2a = create_model(:content_id => 2, :locale => 'ca', :field1 => 'a', :field2 => 'b')
    
    assert_equal_set [], es_1a.translations
    assert_equal_set [], en_1b.translations
    assert_equal_set [en_2a], es_2a.translations
    assert_equal_set [], ca_2a.translations

    # restore
    TestModel.instance_variable_set('@translatable_scopes', [])
  end
  
  def test_should_not_update_translations_if_update_fails
    es_m1 = create_model(:content_id => 1, :locale => 'es', :field2 => 'val')
    ca_m1 = create_model(:content_id => 1, :locale => 'ca', :field2 => 'val')
    TestModel.any_instance.expects(:valid?).returns(false)
    es_m1.update_attributes :field2 => 'newval'
    assert_equal 'val', es_m1.reload.field2
    assert_equal 'val', ca_m1.reload.field2
  end

  def test_should_not_update_translations_if_creation_fails
    es_m1 = create_model(:content_id => 1, :locale => 'es', :field2 => 'val')
    TestModel.any_instance.expects(:valid?).returns(false)
    create_model(:content_id => 1, :locale => 'ca', :field2 => 'newval')
    assert_equal 'val', es_m1.reload.field2
  end
  
  def test_translate_should_create_translation_with_correct_values
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    ca = TestModel.translate(1, 'ca')
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_nil ca.field1
    assert_equal 'val', ca.field2
    assert ca.save
  end

  def test_translate_should_create_new_instance_when_no_valid_content_id
    create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    ca = TestModel.translate(2, 'ca')
    assert_equal nil, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal nil, ca.field1
    assert_equal nil, ca.field2
  end

  def test_translate_should_create_new_instance_when_no_content_id
    create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    ca = TestModel.translate(nil, 'ca')
    assert_equal nil, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal nil, ca.field1
    assert_equal nil, ca.field2
  end
  
  def test_instance_translate_should_create_translation_with_correct_values
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    ca = es.translate('ca')
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_nil ca.field1
    assert_equal 'val', ca.field2
    assert ca.new_record?
  end
  
  def test_translate_with_copy_all_should_copy_common_attributes
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    ca = TestModel.translate(1, 'ca', :copy_all => true)
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal 'val', ca.field1
    assert_equal 'val', ca.field2    
  end
  
  def test_in_locale_instance_method_with_one_locale
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :field1 => 'val', :field2 => 'val')
    assert_equal es.id, en.in_locale('es').id
  end
  
  def test_in_locale_instance_method_with_two_locales
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :field1 => 'val', :field2 => 'val')
    assert_equal es.id, en.in_locale('es', 'en').id
    assert_equal en.id, en.in_locale('en', 'es').id
    assert_equal en.id, en.in_locale('ca', 'en').id
  end
  
  def test_in_locale_instance_method_with_all_locales
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :field1 => 'val', :field2 => 'val')
    assert_equal es.id, en.in_locale('es', :ALL).id
    assert_equal en.id, en.in_locale('en', :ALL).id
    assert_equal en.id, en.in_locale('ca', :ALL).id
    assert_equal es.id, en.in_locale('ca', 'es', :ALL).id
  end
  
  def test_destroy_contents
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :field1 => 'val', :field2 => 'val')
    ca = create_model(:content_id => 1, :locale => 'ca', :field1 => 'val', :field2 => 'val')
    assert_equal 3, TestModel.count
    es.destroy
    assert_equal 2, TestModel.count
    ca.destroy_content
    assert_equal 0, TestModel.count    
  end
  
  def test_compare_locales
    es = create_model(:content_id => 1, :locale => 'es', :field1 => 'val', :field2 => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :field1 => 'val', :field2 => 'val')
    any = create_model(:content_id => 2, :locale => 'any', :field1 => 'val', :field2 => 'val')
    assert es.locale?('es')
    assert en.locale?('es', 'en')
    assert !en.locale?('ca', 'es')
    assert !es.locale?('ca')
    assert any.locale?('en')
    assert any.locale?('jp', 'fr', 'ca', 'es')
    assert any.locale?('any')
  end
end

create_test_model_backend

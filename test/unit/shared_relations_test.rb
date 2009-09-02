require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::TranslatableTest < ActiveSupport::TestCase

  # In these tests names, "simple" involves a non-translatable model, else "translatable" is used

  def test_copy_shared_relations_simple_has_many_case
    TestModel.reflections[:unshared_related_test_models].instance_variable_set('@options',{:translation_shared => true})
    test_model = create_model(:locale => 'ca')
    test_model.unshared_related_test_models << UnsharedRelatedTestModel.create

    # not supported, should fail
    assert_raise RuntimeError do
      test_model.translate('en')
    end

    # check no changes
    assert_equal 1, TestModel.count 
    assert_equal 1, UnsharedRelatedTestModel.count
    TestModel.reflections[:unshared_related_test_models].instance_variable_set('@options', {})
  end

  def test_copy_shared_relations_simple_belongs_to_case
    rel = TranslatableRelatedTestModel.create :locale => 'ca'
    rel.related_test_model = create_related_model
    rel.save
    
    translated = rel.translate('en')
    assert_equal rel.related_test_model, translated.related_test_model

    # check no extra instances created
    assert_equal 1, RelatedTestModel.count
    assert_equal 1, TranslatableRelatedTestModel.count
  end

  # The following 2 tests test duplicity which is currently a disabled behaviour
#  def test_should_copy_shared_relations_simple_has_many_creation_case
#    m1 = create_model(:locale => 'ca')
#    m1.shared_related_test_models << create_related_model(:field1 => '1')
#    m1.shared_related_test_models << create_related_model(:field1 => '2')
#    m2 = m1.translate('en')
#
#    assert_equal 2, m2.shared_related_test_models.size # like m1, but not the same...
#    assert_not_equal m1.shared_related_test_models, m2.shared_related_test_models 
#
#    m2.save
#    assert_equal 4, RelatedTestModel.count # 2 original + 2 duplicated
#    assert_equal 2, RelatedTestModel.count(:conditions => {:field1 => '1'})
#    assert_equal 2, RelatedTestModel.count(:conditions => {:field1 => '2'})
#  end
#
#  def test_should_copy_shared_relations_simple_has_many_update_case
#    m1 = create_model(:locale => 'ca')
#    m1.shared_related_test_models << create_related_model(:field1 => '1')
#    m1.shared_related_test_models << create_related_model(:field1 => '2')
#    m2 = m1.translate('en')
#    m2.save
#    m1.shared_related_test_models = [create_related_model(:field1 => '3')]
#
#    assert_equal 1, m2.reload.shared_related_test_models.size
#    assert_equal 6, RelatedTestModel.count
#    assert_equal 2, RelatedTestModel.count(:conditions => {:field1 => '3'})
#    assert_equal '3', m2.shared_related_test_models.first.field1
#  end

  def test_should_not_copy_relations_as_default_simple_has_many_creation_case
    m1 = create_model(:locale => 'ca')
    m1.unshared_related_test_models << UnsharedRelatedTestModel.create(:field1 => '1')
    m1.unshared_related_test_models << UnsharedRelatedTestModel.create(:field1 => '2')
    m2 = m1.translate('en')

    assert_equal 0, m2.unshared_related_test_models.size
    assert_equal 2, UnsharedRelatedTestModel.count
  end

  def test_should_not_copy_relations_as_default_simple_has_many_update_case_as_default
    m1 = create_model(:locale => 'ca')
    m1.unshared_related_test_models << UnsharedRelatedTestModel.create(:field1 => '1')
    m1.unshared_related_test_models << UnsharedRelatedTestModel.create(:field1 => '2')
    m2 = m1.translate('en')
    m1.unshared_related_test_models = [UnsharedRelatedTestModel.create(:field1 => '3')]

    assert_equal 0, m2.unshared_related_test_models.size
    assert_equal 3, UnsharedRelatedTestModel.count
  end

  def test_should_copy_shared_relations_translatable_has_many_creation_case
    m1 = create_model(:locale => 'ca')
    m1.translatable_related_test_models << create_translatable_related_model(:common => '1', :locale => 'ca')
    m1.translatable_related_test_models << create_translatable_related_model(:common => '2', :locale => 'ca')
    m2 = m1.translate('en')

    assert_equal 2, m2.translatable_related_test_models.size # as m1
    assert_equal %w{en en}, m2.translatable_related_test_models.map(&:locale)
    assert_equal m1.translatable_related_test_models.first.content_id, m2.translatable_related_test_models.first.content_id
    assert_not_equal m1.translatable_related_test_models, m2.translatable_related_test_models 
    assert_equal 4, TranslatableRelatedTestModel.count # 2 original + 2 duplicated
    assert_equal 2, TranslatableRelatedTestModel.count(:conditions => {:common => '1'})
    assert_equal 2, TranslatableRelatedTestModel.count(:conditions => {:common => '2'})
  end

  def test_should_copy_shared_relations_translatable_has_many_update_case
    m1 = create_model(:locale => 'ca')
    m1.translatable_related_test_models << create_translatable_related_model(:common => '1', :locale => 'ca')
    m1.translatable_related_test_models << create_translatable_related_model(:common => '2', :locale => 'ca')
    m2 = m1.translate('en')
    m2.save
    m1.translatable_related_test_models = [create_translatable_related_model(:common => '3', :locale => 'ca')]

    assert_equal 1, m2.reload.translatable_related_test_models.size # as m1
    assert_equal %w{en}, m2.translatable_related_test_models.map(&:locale)
    assert_equal_set m1.translatable_related_test_models.map(&:content_id), m2.translatable_related_test_models.map(&:content_id)
    assert_equal 6, TranslatableRelatedTestModel.count # 2 original + 2 duplicated
    assert_equal 2, TranslatableRelatedTestModel.count(:conditions => {:common => '3'})
  end
  
  def test_should_copy_shared_relations_translatable_chained_creation_case
    a = ChainTestModelA.create(:locale => 'ca', :content_id => 10)
    a.chain_test_model_b = (b = ChainTestModelB.create(:locale => 'ca', :content_id => 20))
    b.chain_test_model_c = (c = ChainTestModelC.create(:locale => 'ca', :content_id => 30))
    c.chain_test_model_a = a
    a.save; b.save; c.save;
    assert_equal a, a.chain_test_model_b.chain_test_model_c.chain_test_model_a

    # The following should trigger chained translation a => b => c
    newa = a.translate('en')
    assert_equal b.content_id, newa.chain_test_model_b.content_id
    assert_equal c.content_id, newa.chain_test_model_b.chain_test_model_c.content_id
    assert_equal 'en', newa.chain_test_model_b.locale
    assert_equal 'en', newa.chain_test_model_b.chain_test_model_c.locale
    assert_equal a, a.chain_test_model_b.chain_test_model_c.chain_test_model_a
    assert_equal newa, newa.chain_test_model_b.chain_test_model_c.chain_test_model_a
  end
  
  def test_should_copy_shared_relations_translatable_has_one_creation_case
    m1 = OneOneTestModel.create(:locale => 'ca', :common => '2')
    m1.one_one = OneOneTestModel.create(:common => '1', :locale => 'ca')
    m1.save
    m2 = m1.translate('en')

    assert_not_nil m2.one_one
    assert_not_nil m1.reload.one_one
    assert_not_equal m1.one_one, m2.one_one
    assert_equal m1.one_one.content_id, m2.one_one.content_id
    assert_equal 'en', m2.one_one.locale
    assert_equal 4, OneOneTestModel.count # 2 original + 2 translated
    assert_equal 2, OneOneTestModel.count(:conditions => {:common => '1'})
    assert_equal 2, OneOneTestModel.count(:conditions => {:common => '2'})
  end
  
  def test_should_get_translated_has_many_elements_from_a_non_translated_model
    non_translated = RelatedTestModel.create
    
    translated_1, translated_2 = [
      TestModel.create(:content_id => 1, :locale => 'en', :related_test_model => non_translated),
      TestModel.create(:content_id => 1, :locale => 'es', :related_test_model => non_translated)
    ]
    
    assert non_translated.valid?
    assert translated_1.valid?
    assert translated_2.valid?
    
    assert_equal [translated_1, translated_2], non_translated.test_models
    assert_equal [translated_1], non_translated.test_models.locale('en')
    assert_equal [translated_2], non_translated.test_models.locale('es')
  end
  
  
  def test_has_many_to_translated_sti
    InheritanceTestModel.destroy_all
    
    test_model = RelatedTestModel.create
    first_inherited = FirstSubclass.create(:field => "Hi", :locale => "en", :related_test_model => test_model)

    assert_equal 1, test_model.inheritance_test_models.size
    
    second_inherited = first_inherited.translate
    second_inherited.field = "Hola"
    second_inherited.locale = 'es'
    second_inherited.related_test_model = test_model

    second_inherited.save

    assert_equal 2, test_model.reload.inheritance_test_models.size
    assert_equal "Hi", test_model.reload.inheritance_test_models.locale("en").first.field
    assert_equal "Hola", test_model.reload.inheritance_test_models.locale("es").first.field
    assert_equal "Hi", test_model.reload.inheritance_test_models.locale("en", 'es').first.field
    assert_equal "Hola", test_model.reload.inheritance_test_models.locale("es", 'en').first.field
  end
  
  def test_translatable_has_many_to_translated_sti_correctly_updates_the_associations
    origin = TranslatableRelatedTestModel.create(:locale => 'en')
    translated_origin = origin.translate('es')
    translated_origin.save

    sti_instance = FirstSubclass.create(:locale => "en", :translatable_related_test_model => origin)

    assert_equal 1, origin.reload.inheritance_test_models.size
    
    translated_sti = sti_instance.translate('es')
    translated_sti.save

    assert_equal 1, origin.reload.inheritance_test_models.size
    assert_equal 1, translated_origin.reload.inheritance_test_models.size
    
    translated_origin.inheritance_test_models = []
    assert_equal [], origin.reload.inheritance_test_models
    
    translated_origin.inheritance_test_models = [translated_sti]
    assert_equal [sti_instance], origin.reload.inheritance_test_models
    
  end
end

create_test_model_backend

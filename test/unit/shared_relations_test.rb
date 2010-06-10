require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::SharedRelationsTest < ActiveSupport::TestCase

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

  def test_copy_shared_relations_simple_belongs_to_case_using_id
    rel = TranslatableRelatedTestModel.create :locale => 'ca'

    translated = rel.translate('en')
    translated.save

    rel.related_test_model_id = create_related_model.id
    rel.save
    assert_equal rel.related_test_model, translated.reload.related_test_model
  end
  
  def test_copy_shared_relations_simple_belongs_update_case
    rel = TranslatableRelatedTestModel.create :locale => 'ca'
    rel.related_test_model = create_related_model
    rel.save

    translated = rel.translate('en')
    translated.save

    new_end = create_related_model
    translated.related_test_model = new_end
    translated.save
    assert_equal new_end.id, translated.reload.related_test_model.id
    assert_equal translated.related_test_model, rel.reload.related_test_model
  end

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
    assert_equal %w{ca ca}, m2.translatable_related_test_models.map(&:locale)
    assert_equal m1.translatable_related_test_models.first.content_id, m2.translatable_related_test_models.first.content_id
    assert_equal m1.translatable_related_test_models, m2.translatable_related_test_models 
    assert_equal 2, TranslatableRelatedTestModel.count
    assert_equal 1, TranslatableRelatedTestModel.count(:conditions => {:common => '1'})
    assert_equal 1, TranslatableRelatedTestModel.count(:conditions => {:common => '2'})
  end

  def test_should_copy_shared_relations_translatable_has_many_update_case
    m1 = create_model(:locale => 'ca')
    m1.translatable_related_test_models << create_translatable_related_model(:common => '1', :locale => 'ca')
    m1.translatable_related_test_models << create_translatable_related_model(:common => '2', :locale => 'ca')
    m2 = m1.translate('en')
    m2.save
    m1.translatable_related_test_models = [create_translatable_related_model(:common => '3', :locale => 'ca')]

    assert_equal 1, m2.reload.translatable_related_test_models.size # as m1
    assert_equal %w{ca}, m2.translatable_related_test_models.map(&:locale)
    assert_equal_set m1.translatable_related_test_models.map(&:content_id), m2.translatable_related_test_models.map(&:content_id)
    assert_equal 3, TranslatableRelatedTestModel.count # 3 original
    assert_equal 1, TranslatableRelatedTestModel.count(:conditions => {:common => '3'})
  end
  
  def test_should_copy_shared_relations_translatable_chained_creation_case
    a = ChainTestModelA.create(:locale => 'ca', :content_id => 10)
    a.chain_test_model_b = (b = ChainTestModelB.create(:locale => 'ca', :content_id => 20))
    b.chain_test_model_c = (c = ChainTestModelC.create(:locale => 'ca', :content_id => 30))
    c.chain_test_model_a = a
    a.save; b.save; c.save;
    assert_equal a, a.chain_test_model_b.chain_test_model_c.chain_test_model_a

    newa = a.translate('en')
    assert_equal b.content_id, newa.chain_test_model_b.content_id
    assert_equal c.content_id, newa.chain_test_model_b.chain_test_model_c.content_id
    assert_equal 'ca', newa.chain_test_model_b.locale
    assert_equal 'ca', newa.chain_test_model_b.chain_test_model_c.locale
    assert_equal a, a.chain_test_model_b.chain_test_model_c.chain_test_model_a

    # newa is not saved, should not be found
    assert_equal a, newa.chain_test_model_b.chain_test_model_c.chain_test_model_a

    newa.save
    assert_equal a.content_id, newa.chain_test_model_b.chain_test_model_c.chain_test_model_a.content_id
  end
  
  def test_should_copy_shared_relations_translatable_has_one_creation_case
    m1 = OneOneTestModel.create(:locale => 'ca', :common => '2')
    m1.one_one = OneOneTestModel.create(:common => '1', :locale => 'ca')
    m1.save
    m2 = m1.translate('en')

    assert_not_nil m2.one_one
    assert_not_nil m1.reload.one_one
    assert_equal m1.one_one, m2.one_one
    assert_equal 'ca', m2.one_one.locale
    assert_equal 2, OneOneTestModel.count
    assert_equal 1, OneOneTestModel.count(:conditions => {:common => '1'})
    assert_equal 1, OneOneTestModel.count(:conditions => {:common => '2'})
  end
  
  def test_should_copy_shared_relations_translatable_has_one_update_case
    ca = OneOneTestModel.create(:locale => 'ca', :independent => 'ca')
    ca.one_one = OneOneTestModel.create(:independent => 'subca', :locale => 'ca')
    ca.save
    en = ca.translate('en')
    en.independent = 'en'
    en.one_one.update_attribute :independent, 'suben'
    en.save
    es = en.reload.translate('es')
    es.independent = 'es'
    es.one_one.update_attribute :independent, 'subes'
    es.save
    es.save
    assert_equal 4, OneOneTestModel.count

    assert_equal 'en', en.reload.independent
    assert_equal 'subes', en.one_one.independent
    assert_equal 'es', es.reload.independent
    assert_equal 'subes', es.one_one.independent
  end
  
  def test_copy_shared_relations_translatable_belongs_to_creation_case
    original = create_model(:locale => 'ca')
    original_relation = create_model(:locale => 'ca')
    original.test_model = original_relation
    original.save

    translated = original.translate('en')
    translated.save

    assert translated.test_model, 'translated instance relation is empty'
    assert_equal original.locale, translated.test_model.locale
    assert_equal original_relation, translated.test_model
    assert_equal 3, TestModel.count
    assert_equal(
      original.id + 2,
      [translated.test_model.id, translated.id].max,
      'instances were created and deleted'
    )
  end

  def test_copy_shared_relations_translatable_belongs_to_update_case
    original = create_model(:locale => 'ca')
    original_relation = create_model(:locale => 'ca')
    original.test_model = original_relation
    original.save

    translated = original.translate('en')
    translated.save

    updated_relation = create_model(:locale => 'en')
    translated.test_model = updated_relation
    translated.save
    
    assert_not_equal original_relation, original.reload.test_model
    assert_equal updated_relation, original.test_model
    assert_equal 4, TestModel.count
    assert_equal(
      original.id + 3,
      [original.test_model.id, original.id].max,
      'instances were created and deleted'
    )
  end

  def test_copy_shared_relations_translatable_belongs_to_update_case_translation_existing
    original = create_model(:locale => 'ca')
    original_relation = create_model(:locale => 'ca')
    original.test_model = original_relation
    original.save

    translated = original.translate('en')
    translated.save

    updated_relation = create_model(:locale => 'en')
    ca_updated_relation = updated_relation.translate('ca')
    ca_updated_relation.save
    
    translated.test_model = updated_relation
    translated.save

    assert_not_equal original_relation, original.reload.test_model
    assert_equal ca_updated_relation, original.reload.test_model
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

    second_inherited.save

    assert_equal 2, test_model.reload.inheritance_test_models.size
    assert_equal "Hi", test_model.inheritance_test_models.locale("en").first.field
    assert_equal "Hola", test_model.inheritance_test_models.locale("es").first.field
    assert_equal "Hi", test_model.inheritance_test_models.locale("en", 'es').first.field
    assert_equal "Hola", test_model.inheritance_test_models.locale("es", 'en').first.field
  end
  
  def test_translatable_has_many_to_translated_sti_correctly_updates_the_associations
    origin = TranslatableRelatedTestModel.create(:locale => 'en')
    translated_origin = origin.translate('es')
    translated_origin.save

    sti_instance = FirstSubclass.create(:locale => "en", :translatable_related_test_model => origin)

    assert_equal 1, origin.reload.inheritance_test_models.size
    
    translated_sti = sti_instance.translate('es', :copy_all => true)
    translated_sti.save

    assert_equal 1, origin.reload.inheritance_test_models.size
    assert_equal 1, translated_origin.reload.inheritance_test_models.size
    
    translated_origin.inheritance_test_models = []
    assert_equal [], origin.reload.inheritance_test_models
    
    translated_origin.inheritance_test_models = [translated_sti]
    assert_equal [sti_instance], origin.reload.inheritance_test_models
    
  end

  def test_should_not_redo_translations_in_has_many_translate_with_copy_all
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << TestModel.create(:locale => 'ca')
    original_id = ca.test_models.first.id
    ca.translate('en', :copy_all => true)
    ca.reload
    assert_equal original_id, ca.test_models.first.id
  end

  def test_should_return_correct_count_in_shared_translations
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << TestModel.create(:locale => 'ca')
    assert_equal 1, ca.test_models.count

    en = ca.translate('en')
    en.save
    assert_equal 1, ca.test_models.count
  end

  def test_should_accept_relations_from_other_locales
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << TestModel.create(:locale => 'ca')
    en = ca.translate('en')
    en.save
    ca.test_models << TestModel.create(:locale => 'en')

    assert_equal 2, ca.test_models.count
    assert_equal 2, en.reload.test_models.count

    en_relation = ca.test_models.last.translate('en')
    en_relation.save

    assert_equal 2, ca.test_models.count
    assert_equal 2, en.test_models.count
  end

end

create_test_model_backend

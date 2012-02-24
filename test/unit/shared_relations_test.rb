require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::SharedRelationsTest < ActiveSupport::TestCase

  # In these tests names, "simple" involves a non-translatable model, else "translatable" is used

  def setup
    Locale.current = Locale.default
  end

  #### Tests of the expected behaviour of :shared_translations in the different association types

  def test_copy_shared_relations_simple_has_many_case
    TestModel.share_translations_for :unshared_related_test_models
    assert_raise RuntimeError do
      create_model
    end
    TestModel.unshare_translations_for :unshared_related_test_models
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
    en.save
    en_one_one = en.one_one.translate('en')
    en_one_one.independent = 'suben'
    en_one_one.save
    assert_equal 4, OneOneTestModel.count

    en.without_current_locale do
      assert_equal 'en', en.reload.independent
      assert_equal 'suben', en.one_one.independent
    end
    Locale.current = 'ca'
    assert_equal 'en', en.reload.independent
    assert_equal 'subca', en.one_one.independent
    Locale.current = 'en'
    assert_equal 'en', en.reload.independent
    assert_equal 'suben', en.one_one.independent
  end

  def test_should_update_foreign_key_in_has_one
    ca = OneOneTestModel.create(:locale => 'ca')
    en = ca.translate('en')
    en.save
    ca.one_one_test_model = assigned = OneOneTestModel.create(:locale => 'en')
    assert_equal assigned, en.reload.one_one_test_model
    en.save
    assert_equal en.id, assigned.reload.one_one_test_model_id
    assert_equal en.id, en.one_one_test_model.one_one_test_model_id # should have been refreshed
  end

  def test_should_copy_shared_relations_translatable_has_one_update_from_the_other_side
    ca = OneOneTestModel.create(:locale => 'ca')
    en = ca.translate('en')
    en.save
    ca.one_one_test_model = assigned = OneOneTestModel.create(:locale => 'en')
    assert_equal assigned, en.reload.one_one_test_model
    en.save
    assert_equal assigned, en.one_one_test_model
    assert_equal en.id, en.one_one_test_model.one_one_test_model_id
    assert_equal assigned, ca.one_one_test_model
  end

  def test_should_copy_shared_relations_translatable_has_one_update_case_without_reassignation
    ca = OneOneTestModel.create(:locale => 'ca')
    en = ca.translate('en')
    en.save
    ca.one_one_test_model = assigned = OneOneTestModel.create(:locale => 'ca')
    assert_equal assigned, en.reload.one_one_test_model
    en.save
    assert_equal assigned, en.one_one_test_model
    assert_equal ca.id, en.one_one_test_model.one_one_test_model_id
    assert_equal assigned, ca.one_one_test_model
  end

  def test_should_not_lose_instance_value_in_a_fresh_has_one_and_updates_foreign_keys
    ca = OneOneTestModel.create(:locale => 'ca')
    ca.one_one_test_model = OneOneTestModel.create(:locale => 'en')
    en = ca.translate('en')
    assert en.one_one_test_model.present?
    en.save
    assert en.one_one_test_model.present?
  end

  def test_should_support_update_foreign_keys_on_has_many_through_to_non_translatable
    ca = TestModel.create(:locale => 'ca')
    target = RelatedTestModel.create
    middle = InheritanceTestModel.create(:locale => 'en', :related_test_model => target)
    ca.inheritance_test_models << middle
    en = ca.translate('en')
    assert_nothing_raised do
      en.save
    end
  end

  def test_copy_shared_relations_translatable_belongs_to_creation_case
    original = create_model(:locale => 'ca')
    original.test_model = original_relation = create_model(:locale => 'ca')
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

    original.without_current_locale do
      assert_not_equal original_relation, original.reload.test_model
      assert_equal ca_updated_relation, original.reload.test_model
    end

    Locale.current = 'ca'
    assert_not_equal original_relation, original.reload.test_model
    assert_equal ca_updated_relation, original.reload.test_model
  end

  #### Tests related to the behaviour of the :destroy option in associations

  def test_has_many_with_common_belongs_to_for_different_translations_and_dependent_destroy_with_explicit_locale
    TestModel.delete_all
    ca_parent = create_model(:locale => 'ca')
    ca_parent.test_models << child_ca = create_model(:locale => 'ca')
    child_en = child_ca.translate('en')
    child_en.save
    ca_parent.test_models << child_en
    ca_parent.reload

    en_parent = ca_parent.translate('en')
    Locale.current = 'en'
    en_parent.save
    assert_equal 'en', Locale.current, 'Locale.current should maintain its value'
    assert_equal [child_en], en_parent.reload.test_models
    Locale.current = 'ca'
    assert_equal [child_ca], ca_parent.reload.test_models

    en_parent.save
    assert_equal en_parent.id, child_en.reload.test_model_id
    ca_parent.save
    assert_equal ca_parent.id, child_ca.reload.test_model_id
    assert_equal 4, TestModel.count
  end

  def test_dependent_destroy_in_has_many_does_delete_childs_when_no_other_translations_exist
    TestModel.delete_all
    parent_ca = create_model(:locale => 'ca')
    parent_es = parent_ca.translate('es')
    parent_es.save
    child_ca = create_model(:locale => 'ca')
    parent_ca.test_models << child_ca
    
    # Delete current parent, child model should point to the other translation
    parent_ca.destroy
    child_ca.reload
    assert_equal parent_es, child_ca.test_model
    
    # Only parent translation available destroy, child record should be also destroyed
    parent_es.destroy
    assert !child_ca.class.find_by_id(child_ca.id)
  end
  
  def test_dependent_destroy_in_has_many_does_not_delete_things_while_translations_exist
    test_dependent_in_has_many_does_not_delete_things_while_translations_exist(:destroy)
  end

  def test_dependent_destroy_in_has_many_only_deletes_own_relation
    test_dependent_in_has_many_only_affects_own_relation(:destroy) do |ca_parent, en_parent, child_en, child_ca|
      assert_difference 'TestModel.count', -2 do
        ca_parent.destroy
      end
      assert en_parent.reload
      Locale.current = 'en'
      assert_equal [child_en], en_parent.test_models
    end
  end

  def test_dependent_nullify_in_has_many_does_not_delete_things_while_translations_exist
    test_dependent_in_has_many_does_not_delete_things_while_translations_exist(:nullify)
  end

  def test_dependent_nullify_in_has_many_only_nullifies_own_relation
    test_dependent_in_has_many_only_affects_own_relation(:nullify) do |ca_parent, en_parent, child_en, child_ca|
      assert_difference 'TestModel.count', -1 do
        ca_parent.destroy
      end
      assert en_parent.reload
      Locale.current = 'en'
      assert_equal [child_en], en_parent.test_models
      assert_nil child_ca.reload.test_model_id
    end
  end

  def test_dependent_delete_all_in_has_many_does_not_delete_things_while_translations_exist
    test_dependent_in_has_many_does_not_delete_things_while_translations_exist(:delete_all)
  end

  def test_dependent_delete_all_in_has_many_only_deletes_own_relation
    test_dependent_in_has_many_only_affects_own_relation(:delete_all) do |ca_parent, en_parent, child_en, child_ca|
      assert_difference 'TestModel.count', -2 do
        ca_parent.destroy
      end
      assert en_parent.reload
      Locale.current = 'en'
      assert_equal [child_en], en_parent.test_models
    end
  end

  #### Tests related to the use of :translation_shared in non-translatable models

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

  def test_should_get_translated_has_many_elements_from_a_non_translated_model_using_default_locale
    non_translated = RelatedTestModel.create

    translated_1, translated_2 = [
      InheritanceTestModel.create(:content_id => 1, :locale => 'en', :related_test_model => non_translated),
      InheritanceTestModel.create(:content_id => 1, :locale => 'es', :related_test_model => non_translated)
    ]

    Locale.current = 'en'
    assert_equal [translated_1], non_translated.inheritance_test_models
    Locale.current = 'es'
    assert_equal [translated_2], non_translated.inheritance_test_models
  end

  def test_should_get_translated_belongs_to_from_a_non_translated_model_using_default_locale
    translated_en = TestModel.create(:locale => 'en')
    translated_ca = translated_en.translate('ca')
    translated_ca.save
    non_translated = RelatedTestModel.create(:tracked_test_model_id => translated_en.id)

    Locale.current = 'en'
    assert_equal translated_en, non_translated.tracked_test_model
    Locale.current = 'ca'
    assert_equal translated_ca, non_translated.tracked_test_model
    Locale.current = 'es'
    assert [translated_ca, translated_en].include?(non_translated.tracked_test_model)
  end

  def test_should_get_translated_has_many_through_elements_to_a_non_translated
    en = TestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    target = RelatedTestModel.create
    middle = InheritanceTestModel.create(:locale => 'en', :related_test_model => target)
    en.inheritance_test_models << middle
    assert_equal [target], ca.through_related_test_models
  end

  def test_should_get_translated_has_many_through_elements_to_a_non_translated_updating_through_case
    en = TestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    target = RelatedTestModel.create
    middle = InheritanceTestModel.create(:locale => 'en', :related_test_model => target)
    en.inheritance_test_models << middle
    assert_equal [target], ca.through_related_test_models
    en.save
    assert_equal [target], ca.through_related_test_models
    en.through_related_test_models = []
    assert_equal [], ca.reload.through_related_test_models
  end

  #### Tests related to using :translation_shared in STI classes

  def test_has_many_to_translated_sti
    InheritanceTestModel.destroy_all

    test_model = RelatedTestModel.create
    first_inherited = FirstSubclass.create(:field => "Hi", :locale => "en", :related_test_model => test_model)

    assert_equal 1, test_model.inheritance_test_models.size

    second_inherited = first_inherited.translate
    second_inherited.field = "Hola"
    second_inherited.locale = 'es'

    assert_difference 'InheritanceTestModel.count' do
      second_inherited.save
    end

    test_model.without_current_locale do
      # this behaviour is almost deprecated (unused), but let's maintain tests
      # to know whether it's really still supported if is necessary in the future
      assert_equal 2, test_model.reload.inheritance_test_models.size
      assert_equal "Hi", test_model.inheritance_test_models.locale("en").first.field
      assert_equal "Hola", test_model.inheritance_test_models.locale("es").first.field
      assert_equal "Hi", test_model.inheritance_test_models.locale("en", 'es').first.field
      assert_equal "Hola", test_model.inheritance_test_models.locale("es", 'en').first.field
    end

    # Now test what happens in the normal workflow
    Locale.current = 'es'
    assert_equal 1, test_model.reload.inheritance_test_models.size
    assert_equal "Hola", test_model.inheritance_test_models.first.field
    Locale.current = 'en'
    assert_equal 1, test_model.reload.inheritance_test_models.size
    assert_equal "Hi", test_model.inheritance_test_models.first.field
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

    translated_origin.inheritance_test_models = [translated_sti.reload]
    assert_equal [sti_instance], origin.reload.inheritance_test_models
  end

  def test_translatable_has_many_to_translated_sti_correctly_updates_the_associations_when_the_change_is_in_the_virtual
    origin = TranslatableRelatedTestModel.create(:locale => 'en')
    translated_origin = origin.translate('es')
    translated_origin.save

    FirstSubclass.create(:locale => "en", :translatable_related_test_model => origin)

    assert_equal 1, origin.reload.inheritance_test_models.size
    assert_equal 1, translated_origin.reload.inheritance_test_models.size

    translated_origin.inheritance_test_models = []
    assert_equal [], origin.reload.inheritance_test_models
  end

  def test_non_translatable_has_many_to_translated_sti_correctly_updates_the_associations
    origin = RelatedTestModel.create

    sti_instance = FirstSubclass.create(:locale => "en", :related_test_model => origin)

    assert_equal 1, origin.reload.inheritance_test_models.count

    translated_sti = sti_instance.translate('es', :copy_all => true)
    translated_sti.save

    origin.without_current_locale do
      assert_equal 2, origin.reload.inheritance_test_models.count
    end
    assert_equal 1, origin.reload.inheritance_test_models.count

    origin.inheritance_test_models = []
    assert_equal [], origin.reload.inheritance_test_models
  end

  #### Tests related to what happens when an association is nullified (special case)

  def test_translatable_belongs_to_correctly_updates_translations_when_nullified_by_attribute_assignation
    origin, translated_origin = create_test_model_with_relation_and_translation

    assert_equal origin.test_model, translated_origin.test_model
    assert_kind_of TestModel, origin.test_model

    origin.test_model_id = nil
    origin.save
    assert_nil origin.test_model_id
    assert_nil origin.reload.test_model
    assert_nil translated_origin.reload.test_model
  end

  def test_translatable_belongs_to_correctly_updates_translations_when_nullified_by_association
    origin, translated_origin = create_test_model_with_relation_and_translation

    origin.test_model = nil
    assert_nil origin.test_model

    origin.save
    assert_nil origin.test_model, 'test_model was restored after a save!'
    assert_nil origin.test_model_id
    assert_nil translated_origin.reload.test_model
  end

  def test_translatable_belongs_to_correctly_updates_translations_when_nullified_by_attribute_update
    origin, translated_origin = create_test_model_with_relation_and_translation
    parent = TestModel.find(origin.test_model.id)

    origin.update_attribute :test_model_id, nil
    assert_nil origin.reload.test_model
    assert_nil translated_origin.reload.test_model

    # now revert and try update_attributes, which is slightly different...
    origin.update_attribute :test_model_id, parent.id
    assert_equal parent, origin.test_model
    origin.update_attributes :test_model_id => nil
    assert_nil origin.test_model
    assert_nil translated_origin.reload.test_model
  end

  def test_translatable_belongs_to_correctly_updates_translations_when_nullified_when_fresh
    origin, translated_origin = create_test_model_with_relation_and_translation
    assert_not_nil origin.test_model

    origin.reload.update_attribute :test_model_id, nil
    assert_nil origin.reload.test_model
    assert_nil translated_origin.reload.test_model
  end

  def test_translatable_has_one_correctly_updates_translations_when_nullified
    en = OneOneTestModel.create(:locale => 'en')
    en.one_one_test_model = OneOneTestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    assert ca.reload.one_one_test_model
    ca.one_one_test_model = nil
    assert_nil ca.one_one_test_model
    assert_nil en.reload.one_one_test_model
  end

  #### Tests related to other circumstances

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

  def test_should_support_mark_for_destruction_objects
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << TestModel.create(:locale => 'ca')
    ca.test_models.first.mark_for_destruction

    en = ca.translate('en')
    en.save
    ca.save
    assert_equal 0, ca.test_models.reload.count
    assert_equal 0, en.test_models.reload.count
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

  def test_should_return_correct_relations_from_other_locales
    Locale.current = 'ca'
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << (ca_relation = TestModel.create(:locale => 'ca'))
    en = ca.translate('en')
    en.save
    ca.test_models << TestModel.create(:locale => 'en')

    assert_equal_set ['ca', 'en'], ca.test_models.map(&:locale)
    assert_equal_set ['ca', 'en'], en.reload.test_models.map(&:locale)

    en_relation = ca_relation.translate('en')
    en_relation.save

    assert_equal_set ['ca', 'en'], ca.test_models.map(&:locale).uniq
    en.without_current_locale do
      assert_equal ['en'], en.test_models.map(&:locale).uniq
    end
    assert_equal_set ['ca', 'en'], ca.test_models.map(&:locale).uniq
  end

  def test_should_return_correct_relations_from_other_locales_belongs_to_case
    ca = TestModel.create(:locale => 'ca')
    ca.test_model = parent = TestModel.create(:locale => 'ca')
    ca.save

    Locale.current = 'en'
    en = ca.translate('en')
    en.save

    parent_en = parent.translate('en')
    # on save, it won't update test_model_id from "en" if it's not loaded
    # this is rails autosave behaviour, and as we want to test it,
    # we load the test_models here before the save
    parent_en.test_models.inspect
    parent_en.save

    ca.without_current_locale do
      assert_equal parent, ca.test_model
    end
    en.without_current_locale do
      # as we don't have current locale, it reads directly the test_model_id field,
      # so a reload is appropiate
      assert_equal parent_en, en.reload.test_model
    end
    Locale.current = 'ca'
    assert_equal parent, ca.test_model
    assert_equal parent, en.test_model
  end

  def test_share_and_unshare_translations_for
    assert !TestModel.reflections[:unshared_related_test_models].is_translation_shared?

    TestModel.class_eval do
      share_translations_for :unshared_related_test_models
    end
    assert TestModel.reflections[:unshared_related_test_models].is_translation_shared?

    TestModel.unshare_translations_for :unshared_related_test_models
    assert !TestModel.reflections[:unshared_related_test_models].is_translation_shared?
  end

  def test_share_and_unshare_translations_for_multiple_times_does_not_crash
    assert !TestModel.reflections[:unshared_related_test_models].is_translation_shared?

    TestModel.class_eval do
      share_translations_for :unshared_related_test_models, :unshared_related_test_models
    end

    TestModel.unshare_translations_for :unshared_related_test_models, :unshared_related_test_models
    assert !TestModel.reflections[:unshared_related_test_models].is_translation_shared?
  end

  def test_share_translations_in_has_many_through_untranslatable_forces_source_table_translatable
    TestModel.reflections[:inheritance_test_models].mark_as_translation_shared(false)
    assert !TestModel.reflections[:inheritance_test_models].is_translation_shared?
    TestModel.unshare_translations_for :through_related_test_models
    TestModel.share_translations_for :through_related_test_models
    assert TestModel.reflections[:inheritance_test_models].is_translation_shared?
  end

  def test_share_translations_for_translation_shared_belongs_to_untranslated
    en = InheritanceTestModel.create(:locale => 'en')
    en.related_test_model = RelatedTestModel.create
    ca = en.translate('ca')
    assert ca.related_test_model
  end

  def test_semi_translated_content_in_a_has_many_avoids_repeated
    en = TestModel.create(:locale => 'en')
    en.test_model = main = TestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    assert_equal ca.test_model, en.test_model
    assert_equal 1, main.test_models.size
    Locale.current = 'en'
    assert_equal 'en', main.test_models.first.locale
  end

  def test_nested_attributes_situation_with_multiple_nil_content_id
    en = TestModel.create
    en.test_models_attributes = [{}, {}]
    assert_equal 2, en.test_models.count
  end

  def test_should_cache_results_for_future_uses
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << TestModel.create(:locale => 'en')
    ca.reload
    ca.expects(:with_translations).once
    2.times { ca.test_models }
  end

  # When we check if an association is already loaded and cached,
  # ensure that we are not being mistaken by ourselves loading it before doing the check.
  # The fact that AssociationProxy is so metal can lead to unexpected loading
  # This test is inspired from a real problem in ubiquo_categories
  def test_should_not_load_association_before_checking_if_it_is_loaded
    ca = TestModel.create(:locale => 'ca')
    ca.test_models << TestModel.create(:locale => 'en')
    en = ca.translate('en')
    en.expects(:association_loaded?).with { |association|
      !association.loaded?
    }
    assert en.test_models.present?
  end

  def test_should_not_tamper_with_nil
    # Rails sometimes returns it instead of an association, but should not be confused
    ca = OneOneTestModel.create(:locale => 'ca')
    nil.expects(:instance_variable_set).never
    assert_nil ca.one_one_test_model
  end

  def test_reload_with_translation_shared_associations
    en = TestModel.create(:locale => 'en')
    en.test_models << child = TestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    assert_equal child, ca.test_models.reload.first
  end

  def test_current_locale_should_have_preference_when_loading_relations
    en = TestModel.create(:locale => 'en')
    en.test_model = main = TestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    Locale.current = 'ca'
    assert_equal 'ca', main.test_models.first.locale
  end

  def test_share_translations_for_translation_shared_has_one
    en = OneOneTestModel.create(:locale => 'en')
    en.one_one_test_model = OneOneTestModel.create(:locale => 'en')
    ca = en.translate('ca')
    ca.save
    assert ca.reload.one_one_test_model
    assert_equal ca.one_one_test_model, en.reload.one_one_test_model
  end

  def test_translation_shared_associations_should_have_correct_finder_sql
    en = TestModel.create(:locale => 'en')
    related1 = TestModel.create(:locale => 'en', :field1 => 'related1')
    related2 = TestModel.create(:locale => 'en', :field1 => 'related2')
    en.test_models << related1
    en.test_models << related2
    ca = en.translate 'ca'
    assert ca.test_models.first(:conditions => {:locale => 'en'})
    assert_nil ca.test_models.first(:conditions => {:locale => 'ca'})
    assert_equal related1, ca.test_models.first(:conditions => { :locale => 'en', :field1 => 'related1' })
    assert_equal related2, ca.test_models.first(:conditions => { :locale => 'en', :field1 => 'related2' })
  end

  def test_translation_shared_associations_should_warn_in_count_with_args
    en = TestModel.create(:locale => 'en')
    en.test_models << TestModel.create(:locale => 'en')
    ca = en.translate 'ca'
    assert_raise NotImplementedError do
      ca.test_models.count(:conditions => {:locale => 'en'})
    end
  end

  def test_update_a_translatable_mode_with_a_has_many_throught_relation
    related_object = ChainTestModelA.new
    model = ChainTestModelA.new(:chain_test_model_as => [related_object])
    assert model.save
    assert_equal [related_object], model.chain_test_model_as
  end

  private

  def create_test_model_with_relation_and_translation
    origin = TestModel.create(:locale => 'en')
    origin.test_model = TestModel.create(:locale => 'en')
    origin.save
    translated_origin = origin.translate('es')
    translated_origin.save
    [origin, translated_origin]
  end

  def test_dependent_in_has_many_does_not_delete_things_while_translations_exist(option)
    prepare_dependency_type(option)
    ca_parent = create_model(:locale => 'ca')
    en_parent = ca_parent.translate('en')
    en_parent.save
    ca_parent.test_models << child_ca = create_model(:locale => 'ca')
    Locale.current = 'ca'
    assert_difference 'TestModel.count', -1 do
      ca_parent.destroy
    end
    Locale.current = 'en'
    assert en_parent.reload
    assert_equal [child_ca], en_parent.test_models
    restore_dependency_type
  end

  def test_dependent_in_has_many_only_affects_own_relation(option)
    prepare_dependency_type(option)
    ca_parent = create_model(:locale => 'ca')
    ca_parent.test_models << child_ca = create_model(:locale => 'ca')
    child_en = child_ca.translate('en')
    child_en.save
    ca_parent.test_models << child_en
    en_parent = ca_parent.translate('en')
    en_parent.save
    ca_parent.reload
    Locale.current = 'ca'
    yield(ca_parent, en_parent, child_en, child_ca)
    restore_dependency_type
  end

  def prepare_dependency_type(option)
    # We use :test_models which by default is :dependent => :destroy, and change
    # the option directly. Then we call the rails existing processor for it.
    # As these are implemented using :before_destroy, we sweep these callbacks
    reflection = TestModel.reflections[:test_models]
    reflection.options[:dependent] = option
    TestModel.instance_variable_set(:@before_destroy_callbacks, nil)
    TestModel.send :configure_dependency_for_has_many, reflection
    reflection.configure_dependency_for_has_many_with_shared_translations
  end

  def restore_dependency_type
    # revert to :dependent => :destroy, which is what is defined in test_helper
    # and what other tests might be expecting
    prepare_dependency_type(:destroy)
  end
end

create_test_model_backend

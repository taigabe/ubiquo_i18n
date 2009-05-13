require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::TranslatableTest < ActiveSupport::TestCase

  def test_should_copy_shared_relations_simple_has_many_creation_case
    m1 = create_model(:locale => 'ca')
    m1.shared_related_test_models << create_related_model(:field1 => '1')
    m1.shared_related_test_models << create_related_model(:field1 => '2')
    m2 = m1.translate('en')

    assert_equal 2, m2.shared_related_test_models.size # like m1, but not the same...
    assert_not_equal m1.shared_related_test_models, m2.shared_related_test_models 

    m2.save
    assert_equal 4, RelatedTestModel.count # 2 original + 2 duplicated
    assert_equal 2, RelatedTestModel.count(:conditions => {:field1 => '1'})
    assert_equal 2, RelatedTestModel.count(:conditions => {:field1 => '2'})
  end

  def test_should_copy_shared_relations_simple_has_many_update_case
    m1 = create_model(:locale => 'ca')
    m1.shared_related_test_models << create_related_model(:field1 => '1')
    m1.shared_related_test_models << create_related_model(:field1 => '2')
    m2 = m1.translate('en')
    m2.save
    m1.shared_related_test_models = [create_related_model(:field1 => '3')]

    assert_equal 1, m2.reload.shared_related_test_models.size
    assert_equal 6, RelatedTestModel.count
    assert_equal 2, RelatedTestModel.count(:conditions => {:field1 => '3'})
    assert_equal '3', m2.shared_related_test_models.first.field1
  end

  def test_should_not_copy_shared_relations_simple_has_many_creation_case_as_default
    m1 = create_model(:locale => 'ca')
    m1.unshared_related_test_models << UnsharedRelatedTestModel.create(:field1 => '1')
    m1.unshared_related_test_models << UnsharedRelatedTestModel.create(:field1 => '2')
    m2 = m1.translate('en')

    assert_equal 0, m2.unshared_related_test_models.size
    assert_equal 2, UnsharedRelatedTestModel.count
  end

  def test_should_not_copy_shared_relations_simple_has_many_update_case_as_default
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
  
end

create_test_model_backend

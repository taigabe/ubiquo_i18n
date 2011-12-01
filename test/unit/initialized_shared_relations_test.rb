require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::InitializedSharedRelationsTest < ActiveSupport::TestCase

  def setup
    Locale.current = Locale.default
    # This will be the association that we'll be using
    TestModel.unshare_translations_for :translatable_related_test_models
  end

  def teardown
    # cleanup of the association we are testing
    TestModel.share_translations_for :translatable_related_test_models
  end

  def test_initialize_translation_for_method_marks_it_correctly_for_a_new_record
    reflection = TestModel.reflections[:translatable_related_test_models]
    assert !reflection.is_translation_shared?
    assert !reflection.is_translation_shared?(TestModel.new)

    TestModel.initialize_translations_for :translatable_related_test_models

    assert !reflection.is_translation_shared?
    assert reflection.is_translation_shared?(TestModel.new)
    assert !reflection.is_translation_shared?(TestModel.create)

    # cleanup
    TestModel.uninitialize_translations_for :translatable_related_test_models
    assert !reflection.is_translation_shared?
    assert !reflection.is_translation_shared?(TestModel.new)
  end

  def test_initialize_translations_works_as_expected_with_translation_records
    en = TestModel.create(:locale => 'en')
    en.translatable_related_test_models << related = TranslatableRelatedTestModel.create
    ca = en.translate('ca')
    assert_equal [], ca.translatable_related_test_models
    TestModel.initialize_translations_for :translatable_related_test_models
    assert_equal [related], ca.translatable_related_test_models
    ca.save
    assert_equal [related], ca.reload.translatable_related_test_models
    assert_equal [], en.reload.translatable_related_test_models
  end

  def test_initialize_translations_works_as_expected_when_there_are_changes
    TestModel.initialize_translations_for :translatable_related_test_models
    en = TestModel.create(:locale => 'en')
    en.translatable_related_test_models << related = TranslatableRelatedTestModel.create
    ca = en.translate('ca')
    ca.translatable_related_test_models = []
    ca.save
    assert_equal [], ca.reload.translatable_related_test_models
    assert_equal [related], en.reload.translatable_related_test_models
    ca.translatable_related_test_models << new_related = TranslatableRelatedTestModel.create
    assert_equal [new_related], ca.reload.translatable_related_test_models
    assert_equal [related], en.reload.translatable_related_test_models
  end

end

create_test_model_backend

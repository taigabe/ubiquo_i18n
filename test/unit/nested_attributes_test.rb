require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::NestedAttributesTest < ActiveSupport::TestCase

  def setup
    Locale.current = Locale.default
  end

  test 'should create a translated relation when the object is new' do
    # This tests the usual situation in a controller, where xxx_attributes
    # can be assigned before the content_id field.
    test_creation_of_translation do |tm|
      [{ "id" => tm.id}]
    end
  end

  test 'should create a translated relation as hash' do
    # tests the same as above but with the other allowed interface
    test_creation_of_translation do |tm|
      {'random' => { "id" => tm.id}}
    end
  end

  test 'should update a translated relation in a one-to-one' do
    Locale.current = 'ca'
    ca = OneOneTestModel.create :locale => 'ca'
    ca.one_one_test_model = shared = OneOneTestModel.create(:locale => 'ca')
    en = ca.translate('en')
    Locale.current = 'en'
    en.one_one_test_model_attributes = { "id" => shared.id}
    assert_difference 'OneOneTestModel.count', 2 do
      en.save
    end
    assert_no_difference 'OneOneTestModel.count' do
      en.one_one_test_model_attributes = { "id" => shared.translations.first.id}
    end
    assert_equal 1, shared.translations.count
  end

  test 'should not affect non-translation-shared relations' do
    instance = RelatedTestModel.create
    assert_nothing_raised do
      instance.test_models_attributes = [{ "field1" => 1}]
    end
    assert_difference 'TestModel.count', 1 do
      instance.save
    end
  end

  test 'should accept nested_attributes for a combination of transltable and not translatable classes' do
    test_model = RelatedTestModel.create(:field1 => 'initial')
    translatable_object = TranslatableRelatedTestModel.create(:shared_related_test_model => test_model)
    assert_no_difference 'TranslatableRelatedTestModel.count' do
      assert_no_difference 'RelatedTestModel.count' do
        translatable_object.update_attributes(
          :shared_related_test_model_attributes => {
            :id => test_model.id,
            :field1 => 'changed'
          }
        )
      end
    end
    assert_equal 'changed', translatable_object.shared_related_test_model.field1
  end

  test 'should update a translated relation, and from another class' do
    Locale.current = 'ca'
    ca = TestModel.create :locale => 'ca'
    ca.inheritance_test_models << itm = InheritanceTestModel.create(:locale => 'ca')
    en = ca.translate('en')
    Locale.current = 'en'
    en.inheritance_test_models_attributes = [{ "id" => itm.id}]
    assert_difference 'TestModel.count' do
      assert_difference 'InheritanceTestModel.count' do
        en.save
      end
    end
    assert_no_difference 'TestModel.count' do
      en.inheritance_test_models_attributes = [{ "id" => itm.translations.first.id}]
    end
    assert_equal 1, itm.translations.count
  end

  test 'should deal correctly with _destroy' do
    Locale.current = 'ca'
    ca = TestModel.create :locale => 'ca'
    ca.inheritance_test_models << itm = InheritanceTestModel.create(:locale => 'ca')
    en = ca.translate('en')
    Locale.current = 'en'
    en.inheritance_test_models_attributes = [{ "id" => itm.id, "_destroy" => "0"}]
    assert_difference 'TestModel.count' do
      assert_difference 'InheritanceTestModel.count' do
        en.save
      end
    end
    assert_equal 1, itm.translations.count
    en.inheritance_test_models_attributes = [{ "id" => itm.translations.first.id, "_destroy" => "1"}]
    assert_no_difference 'TestModel.count' do
      assert_difference 'InheritanceTestModel.count', -2 do
        en.save
      end
    end
    assert_equal [], en.reload.inheritance_test_models
  end

  test 'should deal correctly with _destroy when adding at the same time' do
    Locale.current = 'ca'
    ca = TestModel.create :locale => 'ca'
    ca.inheritance_test_models << itm = InheritanceTestModel.create(:locale => 'ca')
    Locale.current = 'en'
    itm.translate('en').save
    en = ca.translate('en')
    en.save
    en.inheritance_test_models_attributes = [{"_destroy" => ""},{ "id" => itm.translations.first.id, "_destroy" => "1"}]
    assert_no_difference 'TestModel.count' do
      assert_difference 'InheritanceTestModel.count', -2 +1 do
        en.save
      end
    end
  end

  protected

  def test_creation_of_translation
    Locale.current = 'ca'
    ca = TestModel.create :locale => 'ca'
    ca.test_models << tm = TestModel.create(:locale => 'ca')
    en = ca.translate('en')
    en.content_id = nil

    Locale.current = 'en'
    en.test_models_attributes = yield(tm)
    en.content_id = ca.content_id
    assert_difference 'TestModel.count', 2 do
      en.save
    end

    assert_equal 1, tm.translations.count
  end
end

create_test_model_backend

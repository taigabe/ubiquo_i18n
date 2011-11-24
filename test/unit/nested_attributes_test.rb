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

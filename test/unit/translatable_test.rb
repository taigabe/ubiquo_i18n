require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::TranslatableTest < ActiveSupport::TestCase

  def test_should_save_translatable_attributes_list
    ar = create_ar
    ar.class_eval do
      translatable :field1, :field2
    end
    assert_equal [:field1, :field2], ar.instance_variable_get('@translatable_attributes')
  end

  def test_should_accumulate_translatable_attributes_list_from_parent
    ar = create_ar
    ar.class_eval do
      translatable :field1, :field2
    end
    son = Class.new(ar)
    son.class_eval do
      translatable :field3, :field4
    end
    assert_equal [:field1, :field2, :field3, :field4], son.instance_variable_get('@translatable_attributes')
    gson = Class.new(son)
    gson.class_eval do
      translatable :field5
    end
    assert_equal [:field1, :field2, :field3, :field4, :field5], gson.instance_variable_get('@translatable_attributes')
  end
  
#  def test_should_add_locale_relation
#    ar = create_ar
#    ar.class_eval do
#      translatable
#    end
#    assert_not_nil ar.reflections[:related_locale]
#  end
#
  def test_should_store_locale
    # For this test, we will make locale itself translatable, since we need an existing AR
    Locale.class_eval do
      attr_accessor :locale
      translatable
    end
    locale = create_locale(:iso_code => 'ca', :locale => 'ca')
    assert String === locale.locale
    assert_equal locale.iso_code, locale.locale
  end

  def test_should_store_string_locale_in_dual_format
    # For this test, we will make locale itself translatable, since we need an existing AR
    Locale.class_eval do
      attr_accessor :locale
      translatable
    end
    locale = create_locale(:iso_code => 'ca', :locale => 'ca')
    new_locale = create_locale(:iso_code => 'en', :locale => locale)    
    assert_equal 'ca', new_locale.locale
    assert_equal locale.iso_code, locale.locale
  end

  private
    
  def create_ar(options = {})
    Class.new(ActiveRecord::Base)
  end
  
end

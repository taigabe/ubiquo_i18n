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

  private
    
  def create_ar(options = {})
    Class.new(ActiveRecord::Base)
  end
  
end

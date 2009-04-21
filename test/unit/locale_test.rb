require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::LocaleTest < ActiveSupport::TestCase
  
  def test_should_create_locale
    assert_difference 'Locale.count' do
      locale = create_locale
      assert !locale.new_record?, "#{locale.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_iso_code
    assert_no_difference 'Locale.count' do
      l = create_locale(:iso_code => nil)
      assert l.errors.on(:iso_code)
    end
  end
  
  def test_should_require_unique_iso_code
    assert_difference 'Locale.count', 1 do
      l = create_locale(:iso_code => "en")
      assert !l.new_record?
      
      l = create_locale(:iso_code => "en")
      assert l.errors.on(:iso_code)
    end
  end
  
  def test_should_use_different_locale
    Locale.current = 'en'
    Locale.using_locale('es') do
      assert_equal 'es', Locale.current
    end
    assert_equal 'en', Locale.current
  end
    
  def test_should_get_current_locale
    Ubiquo::Config.context(:ubiquo_i18n).set(:current_locale, 'test')
    assert_equal 'test', Locale.current    
  end
      
end

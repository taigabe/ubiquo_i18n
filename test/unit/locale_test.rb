require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::LocaleTest < ActiveSupport::TestCase

  def teardown
    Locale.current = nil
  end

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

  def test_should_store_current_locale
    Locale.current = 'ca'
    assert_equal 'ca', Locale.current
  end

  def test_should_store_current_locale_as_symbol
    Locale.current = :ca
    assert_equal :ca, Locale.current
  end

end

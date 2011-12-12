require File.dirname(__FILE__) + "/../test_helper.rb"

class RoutingTest < Test::Unit::TestCase

  def test_should_recognize_localized_routes
    Locale.active.map(&:to_s).each do |locale|
      expected = { :controller => "ubiquo/locales",
                   :action     => "show",
                   :locale     => locale }
      assert_recognition :get, "/ubiquo/#{locale}/locales", expected
    end
  end

  def test_should_generate_localized_routes
    Locale.active.map(&:to_s).each do |locale|
      options = { :controller => "ubiquo/locales",
                  :action     => "show",
                  :locale     => locale }
      expected = "/ubiquo/#{locale}/locales"
      assert_generation expected, options
    end
  end

  private

  def assert_recognition(method, path, options)
    result = ActionController::Routing::Routes.recognize_path(path, :method => method)
    assert_equal options, result
  end

  def assert_generation(expected, options)
    result = ActionController::Routing::Routes.generate(options)
    assert_equal expected, result
  end
end

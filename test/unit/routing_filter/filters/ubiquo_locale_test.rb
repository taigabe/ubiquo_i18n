require File.dirname(__FILE__) + "/../../../test_helper.rb"

include RoutingFilter

class SomeController < ActionController::Base
  def index; end
  def other; end
end
class Ubiquo::SomeController < ActionController::Base
  def index; end
  def other; end
end

if ActionPack::VERSION::MAJOR == 2
  ActionController::Routing::RouteSet::Mapper.class_eval do
    # rails 3 routes creation, for fallback
    def match(pattern, options)
      pattern.gsub!('(.:format)', '.:format')
      controller, action = options.delete(:to).split('#')
      options.merge!(:controller => controller, :action => action)
      connect(pattern, options)
    end
  end
end

# test based on the local_filter test from the gem routing-filter
class UbiquoLocaleTest < Test::Unit::TestCase
  attr_reader :routes, :ubiquo_params, :public_params

  def setup
    Locale.delete_all
    %w(en es ca).each do |locale|
      create_locale :iso_code   => locale,
                    :is_active  => true,
                    :is_default => true
    end

    # in this tests, allways clean the url params
    Ubiquo::Settings.context(:ubiquo_i18n).set(:clean_url_params, lambda { true })

    @ubiquo_params = { :controller => 'ubiquo/some', :action => 'index' }
    @public_params = { :controller => 'some', :action => 'index' }

    @routes = draw_routes do
      filter :ubiquo_locale
      match 'ubiquo',             :to => 'ubiquo/some#index'
      match 'ubiquo/other',       :to => 'ubiquo/some#other'
      match '/dashboard/:locale', :to => 'some#index'
      match '/other',             :to => 'some#other'
    end
  end

  def test_should_recognize_localized_routes_inside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = ubiquo_params.merge(:locale => locale)
      result   = routes.recognize_path("/ubiquo/#{locale}")
      assert_equal expected, result

      expected = ubiquo_params.merge(:action => 'other', :locale => locale)
      result   = routes.recognize_path("/ubiquo/#{locale}/other")
      assert_equal expected, result
    end
  end

  def test_should_generate_localized_routes_inside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = "/ubiquo/#{locale}"
      result   = routes.generate(ubiquo_params.merge(:locale => locale))
      assert_equal expected, result

      expected = "/ubiquo/#{locale}/other"
      result   = routes.generate(ubiquo_params.merge(:locale => locale, :action => 'other'))
      assert_equal expected, result
    end
  end

  def test_should_recognize_routes_outside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = public_params.merge(:locale => locale)
      result   = routes.recognize_path("/dashboard/#{locale}")
      assert_equal expected, result
    end

    expected = public_params.merge(:action => 'other')
    result   = routes.recognize_path("/other")
    assert_equal expected, result
  end

  def test_should_generate_routes_outside_ubiquo_area
    Locale.active.map(&:to_s).each do |locale|
      expected = "/dashboard/#{locale}"
      result   = routes.generate(public_params.merge(:locale => locale))
      assert_equal expected, result
    end

    expected = "/other"
    result   = routes.generate(public_params.merge(:action => 'other'))
    assert_equal expected, result
  end

  protected

  def draw_routes(&block)
    normalized_block = rails_2? ? lambda { |set| set.instance_eval(&block) } : block
    klass = rails_2? ? ActionController::Routing::RouteSet : ActionDispatch::Routing::RouteSet
    klass.new.tap { |set| set.draw(&normalized_block) }
  end

  def rails_2?
    ActionPack::VERSION::MAJOR == 2
  end
end

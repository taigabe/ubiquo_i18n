require File.dirname(__FILE__) + "/../test_helper.rb"

class ExampleApplicationControllerTest < ActionController::TestCase
  test "by default, Locale.use_fallbacks is false" do
    Locale.use_fallbacks = true
    get :show
    assert !Locale.use_fallbacks
  end
end

# Bare application controller to test any expected default behaviour
class ExampleApplicationController < ApplicationController
  def show
    render :nothing => true
  end
end

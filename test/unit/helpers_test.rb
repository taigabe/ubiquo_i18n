require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoI18n::Extensions::HelpersTest < ActionView::TestCase

  def test_locale_selector_displays_select
    html_content = HTML::Document.new(locale_selector)
    assert_select html_content.root, "form" do
      assert_select 'select'
    end
  end

  def test_locale_selector_deletes_page_by_default
    html_content = HTML::Document.new(locale_selector)
    assert_select html_content.root,  ['form[action=?]', /page.+/], false
  end

  def test_locale_selector_accepts_keep_page_option
    html_content = HTML::Document.new(locale_selector(:keep_page => true))
    assert_select html_content.root, 'form[action=?]', /page.+/
  end

  def test_show_translations_for_a_existing_object
    model = create_model(:locale => 'test')
    self.expects(:render).once.with(
      :partial =>  "shared/ubiquo/model_translations",
      :locals => { :model => model, :options => {} }
    ).returns(true)

    assert show_translations(model)
  end

  def test_show_translations_should_be_rendered_for_objects_that_have_a_persistent_translation
    existing_model = create_model(:locale => 'test')
    model = existing_model.translate('test2')

    self.expects(:render).once.with(
      :partial =>  "shared/ubiquo/model_translations",
      :locals => { :model => model, :options => {} }
    )
    assert show_translations(model)
  end

  def test_show_translations_should_be_rendered_for_objects_that_have_a_persistent_translation
    model = TestModel.new(:locale => 'test')
    self.expects(:render).never.with(
      :partial =>  "shared/ubiquo/model_translations",
      :locals => { :model => model, :options => {} }
    )

    assert !show_translations(model)
  end

  def test_show_translations_should_not_render_anything_for_object_with_locale_any
    model = create_model(:locale => 'any')
     self.expects(:render).never.with(
      :partial =>  "shared/ubiquo/model_translations",
      :locals => { :model => model, :options => {} }
    )

    assert !show_translations(model)
  end

  def test_show_translations_should_pass_options_to_the_view
    model = create_model(:locale => 'any')
     self.expects(:render).never.with(
      :partial =>  "shared/ubiquo/model_translations",
      :locals => { :model => model, :options => { :my_options => true } }
    )

    assert !show_translations(model, :my_option => true)
  end

  # Some stubs for helpers
  UbiquoI18n::Extensions::Helpers.module_eval do
    include Ubiquo::Helpers::CorePublicHelpers

    def params
      {:page => '1'}
    end

    def url_for(options = {})
      options.to_s
    end

    def current_locale
      'ca'
    end
  end

end

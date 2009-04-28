module UbiquoI18n
  module Extensions
    module Helpers
      def locale_selector
        good_params = params.dup
        good_params.delete(:page) # removed page preventing wrong page number in new locale
        form_tag(url_for(good_params), :method => :get) +
          html_unescape(select_tag( "locale", 
            options_from_collection_for_select(Locale.active.all, :iso_code, :native_name, current_locale),
            :onchange => "up('form').submit();"
            )) +
          "</form>"
      end
      
      def show_translations(model, options = {})
        render :partial => "shared/ubiquo/model_translations", :locals => {:model => model}
      end
    end
  end
end

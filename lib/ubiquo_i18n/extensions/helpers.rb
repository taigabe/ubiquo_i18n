module UbiquoI18n
  module Extensions
    
    # This module provides some builtin helpers to be used in views
    module Helpers
      
      # Returns a selector of the currently active locales, ordered alphabetically, 
      # with the current locale selected
      def locale_selector
        good_params = params.dup
        good_params.delete(:page) # removed page preventing wrong page number in new locale
        if Locale.active.size > 1
          form_tag(url_for(good_params), :method => :get) +
            html_unescape(select_tag( "locale", 
              options_from_collection_for_select(Locale.active.ordered_alphabetically.all, :iso_code, :native_name, current_locale),
              :onchange => "up('form').submit();"
              )) +
            "</form>"
        end
      end
      
      # For a given model, show their translations with a link to them
      def show_translations(model, options = {})
        return if model.locale?(:any)
        render :partial => "shared/ubiquo/model_translations", :locals => {:model => model}
      end
      
      # Adds a tab to display the locales section inside superadmin area
      def superadmin_locales_tab(navtab)
        navtab.add_tab do |tab|
          tab.text = I18n.t("ubiquo.i18n.translations")
          tab.title = I18n.t("ubiquo.i18n.translations_title")
          tab.highlights_on({:controller => "ubiquo/locales"})
          tab.link = ubiquo_locales_path
        end if ubiquo_config_call(:assets_permit, {:context => :ubiquo_media})
      end
    end
  end
end

map.namespace :ubiquo do |ubiquo|
  ubiquo.resource :locales

  map.filter :ubiquo_locale
end

if Rails.env.test?
  map.connect 'example_route', :controller => 'example_application', :action => 'show'
end
Rails.application.routes.draw do

  resources :mt_resources
  root 'static_pages#home'

  resources :events do
    get :autocomplete_person_name, :on => :collection
  end
  resources :impact_reports, except: [:new, :create] do
    collection do
      get 'tag'
      get 'tag/:month', to: 'impact_reports#tag', as: 'tag_month'
      post 'spreadsheet', to: 'impact_reports#spreadsheet', as: 'spreadsheet'
    end
    get 'tag', on: :collection
    member do
      patch 'tag_update'
      patch 'archive'
      patch 'unarchive'
      patch 'not_impact'
    end
  end
  resources :languages
  resources :people do
    get :contacts, on: :collection
  end
  resources :reports do
    collection do
      get 'by_language'
      get 'by_topic'
      get 'by_reporter'
    end
    member do
      patch 'archive'
      patch 'unarchive'
    end
  end
  resources :tallies
  resources :topics
  resources :users

  get    'adduser' => 'users#new'

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  
  get    'roles'   => 'roles#index'
  patch  'roles'   => 'roles#update'
  post   'roles'   => 'roles#create'

  get  'tally_updates' => 'tally_updates#index'
  post 'tally_updates' => 'tally_updates#create'

  get 'events/new'

  get 'outcomes/select' => 'topics#assess_progress_select', as: 'select_to_assess'
  get 'outcomes/get_chart/:id' => 'state_languages#get_chart', as: 'outcomes_chart'
  get 'outcomes/get_totals_chart/:id' => 'geo_states#get_totals_chart', as: 'outcomes_totals_chart'
  get 'outcomes/table/:id' => 'state_languages#get_table', as: 'outcomes_table'
  get 'outcomes/:geo_state_id/:language_id/:yearmonth' => 'topics#assess_progress', as: 'assess_progress'
  post 'outcomes/:geo_state_id/:language_id/:yearmonth' => 'topics#update_progress'
  get 'outcomes' => 'state_languages#outcomes', as: 'outcomes'
  get 'outcomes/:id' => 'state_languages#outcomes_data'

  get 'outputs/report_numbers' => 'output_tallies#report_numbers', as: 'report_numbers'
  post 'outputs/report_numbers' => 'output_tallies#update_numbers', as: 'update_numbers'
  get 'outputs' => 'output_tallies#table', as: 'outputs'
  get 'outputs/:id' => 'languages#outputs_table'

  get 'language/resources/:language_id' => 'mt_resources#language_overview'

  get 'overview' => 'state_languages#overview', as: 'overview'
  get 'overview/show_outcomes_progress/:id' => 'state_languages#show_outcomes_progress', as: 'show_outcomes_progress'
  get 'states/autocomplete_district_name/:geo_state_id' => 'geo_states#autocomplete_district_name', as: 'autocomplete_district_name_geo_state'
  get 'states/autocomplete_sub_district_name/:district_id' => 'districts#autocomplete_sub_district_name', as: 'autocomplete_sub_district_name_district'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end

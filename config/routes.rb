Rails.application.routes.draw do

  root 'static_pages#home'

  get 'tasks' => 'static_pages#tasks'

  resources :edits, only: [:create, :destroy] do
    collection do
      get 'curate'
      get 'my'
      patch 'add_creator_comment', as: 'add_creator_comment_to'
      patch 'add_curator_comment', as: 'add_curator_comment_to'
    end
    member do
      patch 'approve'
      patch 'reject'
    end
  end
  resources :events do
    get :autocomplete_person_name, :on => :collection
  end

  resources :geo_states, only: [:show]

  resources :impact_reports, except: [:new, :create, :index] do
    collection do
      get 'tag'
      get 'tag/:month', to: 'impact_reports#tag', as: 'tag_month'
    end
    get 'tag', on: :collection
    member do
      patch 'tag_update'
      patch 'archive'
      patch 'unarchive'
      patch 'not_impact'
      patch 'shareable'
      patch 'not_shareable'
    end
  end
  resources :languages do
    collection do
      get 'overview'
      get 'search'
    end
    member do
      get 'show_details'
      patch 'add_engaged_org/:org', to: 'languages#add_engaged_org', as: 'add_engaged_org_to'
      patch 'remove_engaged_org/:org', to: 'languages#remove_engaged_org', as: 'remove_engaged_org_from'
      patch 'add_translating_org/:org', to: 'languages#add_translating_org', as: 'add_translating_org_to'
      patch 'remove_translating_org/:org', to: 'languages#remove_translating_org', as: 'remove_translating_org_from'
      patch 'set_finish_line_progress/:marker/:progress', to: 'languages#set_finish_line_progress', as: 'set_flp_for'
      # This is a hack to work around something I haven't worked out yet.
      get 'set_finish_line_progress/:marker/:progress', to: 'languages#show'
    end
  end
  resources :mt_resources
  resources :organisations
  resources :people do
    get :contacts, on: :collection
  end
  resources :reports do
    collection do
      get 'by_language'
      get 'by_topic'
      get 'by_reporter'
      post 'spreadsheet', to: 'reports#spreadsheet', as: 'spreadsheet'
      post 'create_external'
      get 'index_external'
    end
    member do
      patch 'archive'
      patch 'unarchive'
      get 'pictures'
    end
  end

  resources :topics

  resources :users do
    collection do
      post :show_external
      get :index_external
    end

    member do
      get :confirm_email
    end
  end

  resources :zones, only: [:index, :show]

  get 're_send_to_confirm_email' => 'users#re_confirm_email'

  get    'adduser' => 'users#new'

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  post   'two_factor_auth'   => 'sessions#two_factor_auth'
  get 'otp_poll/:ticket' => 'sessions#poll', as: 'otp_poll'
  post 'resend_code_to_phone' => 'sessions#resend_otp_to_phone', as: 'resend_code_to_phone'
  post 'resend_code_to_email' => 'sessions#resend_otp_to_email', as: 'resend_code_to_email'
  delete 'logout'  => 'sessions#destroy'
  post   'sessions/create_external'


  get  'tally_updates' => 'tally_updates#index'
  post 'tally_updates' => 'tally_updates#create'

  get 'events/new'

  get 'languages/fetch_jp_data/:iso' => 'languages#fetch_jp_data', as: 'fetch_jp_data'

  get 'outcomes/select' => 'topics#assess_progress_select', as: 'select_to_assess'
  get 'outcomes/get_chart/:id' => 'state_languages#get_chart', as: 'outcomes_chart'
  get 'outcomes/get_language_chart/:id' => 'languages#get_chart', as: 'language_outcomes_chart'
  get 'outcomes/get_totals_chart/:id' => 'geo_states#get_totals_chart', as: 'outcomes_totals_chart'
  get 'outcomes/get_combined_languages_chart/:id' => 'geo_states#get_combined_languages_chart', as: 'combined_languages_chart'
  get 'outcomes/get_outcome_area_chart/:id/:topic_id' => 'geo_states#get_outcome_area_chart', as: 'outcome_area_chart'
  get 'outcomes/table/:id' => 'state_languages#get_table', as: 'outcomes_table'
  get 'outcomes/:state_language_id/:months' => 'topics#assess_progress', as: 'assess_progress'
  get 'outcomes/:state_language_id/:months.pdf' => 'topics#assess_progress', as: 'assess_progress_pdf'
  post 'outcomes/:state_language_id/:months' => 'topics#update_progress'
  get 'outcomes' => 'state_languages#outcomes', as: 'outcomes'
  get 'outcomes/:id' => 'state_languages#outcomes_data'

  get 'outputs/report_numbers' => 'output_tallies#report_numbers', as: 'report_numbers'
  post 'outputs/report_numbers' => 'output_tallies#update_numbers', as: 'update_numbers'
  get 'outputs' => 'output_tallies#table', as: 'outputs'
  get 'outputs/:id' => 'languages#outputs_table'

  get 'language/resources/:language_id' => 'mt_resources#language_overview'

  get 'overview' => 'state_languages#overview', as: 'overview'
  get 'transformation' => 'state_languages#transformation', as: 'transformation'
  get 'transformation_spreadsheet' => 'state_languages#transformation_spreadsheet', as: 'transformation_spreadsheet'
  get 'overview/show_outcomes_progress/:id' => 'state_languages#show_outcomes_progress', as: 'show_outcomes_progress'
  get 'states/autocomplete_district_name/:geo_state_id' => 'geo_states#autocomplete_district_name', as: 'autocomplete_district_name_geo_state'
  get 'states/autocomplete_sub_district_name/:district_id' => 'districts#autocomplete_sub_district_name', as: 'autocomplete_sub_district_name_district'

  get 'nation' => 'zones#nation', as: 'nation'

  get 'whatsapp' => 'static_pages#whatsapp_link'

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

Rails.application.routes.draw do

  root 'zones#index'

  patch 'aggregate_ministry_outputs/update_comment'

  resources :android_additions do
    collection do
      get  'test_server'
      post 'new_user_info'
      post 'new_user'
      post 'new_user'
      post 'forgot_password'
      post 'login'
      post 'send_otp'
      post 'get_database_key'
      post 'get_file'
    end
  end

  resources :android_sync do
    collection do
      post 'send_request'
      post 'get_uploaded_file'
      post 'receive_request'
      post 'get_file'
    end
  end

  get 'states/autocomplete_sub_district_name/:district_id' => 'districts#autocomplete_sub_district_name', as: 'autocomplete_sub_district_name_district'

  resources :church_teams, only: [] do
    member do
      get 'project_table/:project_id', action: :project_table, as: 'table_for'
      get 'qr_table/:project_id/:stream_id/:first_month', action: :quarterly_table, as: 'quarterly_table_for'
    end
  end

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

  get 'events/new'

  resources :facilitator_feedbacks, only: [:create, :update]
  
  resources :geo_states, only: [:show] do
    member do
      get :bulk_assess, as: 'bulk_assess'
      post :bulk_progress_update
      get :reports
      get :load_flm_summary
      get :load_flt_summary
      get :load_language_flm_table
      get :load_board_report
    end
  end
  get 'outcomes/get_totals_chart/:id' => 'geo_states#get_totals_chart', as: 'outcomes_totals_chart'
  get 'outcomes/get_combined_languages_chart/:id' => 'geo_states#get_combined_languages_chart', as: 'combined_languages_chart'
  get 'outcomes/get_outcome_area_chart/:id/:topic_id' => 'geo_states#get_outcome_area_chart', as: 'outcome_area_chart'
  get 'states/autocomplete_district_name/:geo_state_id' => 'geo_states#autocomplete_district_name', as: 'autocomplete_district_name_geo_state'

  scope :help, controller: 'help' do
    get 'edit_language'
  end
  get 'help/edit_language'


  resources :impact_reports, except: [:new, :create, :index] do
    member do
      get 'tag'
      patch 'tag_update'
      patch 'archive'
      patch 'unarchive'
      patch 'not_impact'
      patch 'shareable'
      patch 'not_shareable'
    end
  end

  resources :languages, except: [:index, :edit, :update] do
    collection do
      get :autocomplete_user_name
      get 'search'
    end
    member do
      get 'show_details'
      get 'reports'
      patch 'assign_project', to: 'languages#assign_project'
      patch 'set_champion'
      patch 'add_engaged_org/:org', to: 'languages#add_engaged_org', as: 'add_engaged_org_to'
      patch 'remove_engaged_org/:org', to: 'languages#remove_engaged_org', as: 'remove_engaged_org_from'
      patch 'add_translating_org/:org', to: 'languages#add_translating_org', as: 'add_translating_org_to'
      patch 'remove_translating_org/:org', to: 'languages#remove_translating_org', as: 'remove_translating_org_from'
      patch 'set_finish_line_progress/:marker', to: 'languages#set_finish_line_progress', as: 'set_flp_for'
      # This is a hack to work around something I haven't worked out yet.
      get 'set_finish_line_progress/:marker/:progress', to: 'languages#show'
      get 'populations'
    end
  end
  get 'outcomes/get_language_chart/:id' => 'languages#get_chart', as: 'language_outcomes_chart'
  get 'languages/fetch_jp_data/:iso' => 'languages#fetch_jp_data', as: 'fetch_jp_data'
  get 'language_tab_spreadsheet' => 'languages#language_tab_spreadsheet', as: 'language_tab_spreadsheet'
  get 'add_finish_line_progress' => 'languages#add_finish_line_progress', as: 'add_finish_line_progress'
  get 'change_future_year' => 'languages#change_future_year'

  resources :language_streams, only: [:show, :destroy, :update]

  resource :ministries, only: [] do
    get ':id/projects_overview/:quarter', on: :member, action: 'projects_overview', as: 'projects_overview_for'
  end

  resources :ministry_outputs, only: [:update, :create]

  resources :mt_resources
  get 'language/resources/:language_id' => 'mt_resources#language_overview'

  resources :organisations

  resources :password_resets, only: [:new, :create, :edit, :update]
  get 'update_reset' => 'password_resets#approve_user_request'
  patch 'update_reset' => 'password_resets#reject_user_request'
  get 'verify_otp'   => 'password_resets#verify'
  post 'verify_otp'  => 'password_resets#verify_otp'
  post 'change_password' => 'password_resets#password_change'

  scope :pb, controller: 'pb_api' do
    post 'authenticate', action: :jwt
    get 'language/:iso', action: :language_details
    get 'spreadsheet', action: :spreadsheet, as: 'pb_spreadsheet'
  end

  resources :people do
    get :contacts, on: :collection
  end

  resources :phone_messages, only: [] do
    get :pending, on: :collection
    patch :update, on: :collection
    get :poll, on: :member
  end

  resources :populations, only: [:create]
  get 'population/create'

  resources :projects, except: [:index] do
    member do
      get 'teams'
      get 'team_deliverables/:team_id', action: 'team_deliverables', as: 'team_deliverables_in'
      get 'facilitators'
      get 'quarterly'
      get 'edit_responsible'
      get 'targets_by_language/:state_language', action: 'targets_by_language', as: 'targets_by_language_in'
      patch 'set_language/:state_language', action: 'set_language', as: 'set_language_in'
      patch 'set_stream/:ministry', action: 'set_stream', as: 'set_stream_in'
      patch 'add_facilitator/:stream/:state_language/:facilitator', action: 'add_facilitator', as: 'add_facilitator_to'
    end
  end

  resources :project_progresses, only: [:update, :create]

  patch 'project_streams/:id/set_supervisor/:supervisor', to: 'project_streams#set_supervisor', as: 'set_supervisor_in_project_stream'

  resources :project_supervisors, only: [:create, :destroy, :update]

  resources :quarterly_evaluations, only: [:update] do
    member do
      patch 'select_report/:report', action: 'select_report', as: 'select_report_for'
      post 'add_report', action: 'add_report', as: 'add_report_for'
    end
  end

  resources :reports do
    collection do
      post 'spreadsheet', to: 'reports#spreadsheet', as: 'spreadsheet'
      get :autocomplete_person_name
    end
    member do
      patch 'archive'
      patch 'unarchive'
      get 'pictures'
    end
  end

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  post   'two_factor_auth'   => 'sessions#two_factor_auth'
  post 'resend_code_to_phone' => 'sessions#resend_otp_to_phone', as: 'resend_code_to_phone'
  post 'resend_code_to_email' => 'sessions#resend_otp_to_email', as: 'resend_code_to_email'
  delete 'logout'  => 'sessions#destroy'
  get 'session/change/:id' => 'sessions#change'
  get 'signup' => 'sessions#sign_up'
  get 'password_reset/:user_id/:token' => 'sessions#two_factor_auth', as: 'reset_password'

  resources :state_languages, only: [] do
    member do
      patch 'set_target/:deliverable/:quarter', action: 'set_target', as: 'set_target_in'
      patch 'set_amo_actual/:deliverable/:month/:facilitator', action: 'set_amo_actual', as: 'set_amo_actual_in'
      patch 'copy_targets_from/:source/:project', action: 'copy_targets', as: 'copy_targets_to'
      get 'quarterly_report/:project/:sub_project/:stream/:quarter', action: 'quarterly_report', as: 'quarterly_report'
    end
  end
  get 'finish_line_marker_spreadsheet' => 'state_languages#finish_line_marker_spreadsheet', as: 'finish_line_marker_spreadsheet'
  get 'outcomes' => 'state_languages#outcomes', as: 'outcomes'
  get 'outcomes/:id' => 'state_languages#outcomes_data'
  get 'transformation_spreadsheet' => 'state_languages#transformation_spreadsheet', as: 'transformation_spreadsheet'
  get 'overview/show_outcomes_progress/:id' => 'state_languages#show_outcomes_progress', as: 'show_outcomes_progress'
  get 'overview' => 'state_languages#overview', as: 'overview'
  get 'transformation' => 'state_languages#transformation', as: 'transformation'
  get 'outcomes/get_chart/:id' => 'state_languages#get_chart', as: 'outcomes_chart'
  get 'outcomes/table/:id' => 'state_languages#get_table', as: 'outcomes_table'

  resources :sub_projects, only: [:create, :destroy] do
    get :quarterly_report, on: :member
    get 'download_report/:quarter', on: :member, action: :download_quarterly_report, as: 'download_report_for'
    get 'funders_report/:quarter', on: :member, action: :funders_quarterly_report, as: 'funders_report_for', format: 'docx'
    get 'populate_stream_headers/:state_language/:quarter', on: :member, action: :populate_stream_headers, as: 'populate_stream_headers_for'
    get 'populate_lang_headers/:stream/:quarter', on: :member, action: :populate_lang_headers, as: 'populate_lang_headers_for'
  end

  resources :supervisor_feedbacks, only: [:update, :create]

  get 'outcomes/:state_language_id/:months' => 'topics#assess_progress', as: 'assess_progress'
  get 'outcomes/:state_language_id/:months.pdf' => 'topics#assess_progress', as: 'assess_progress_pdf'
  post 'outcomes/:state_language_id/:months' => 'topics#update_progress'
  get 'outcomes/select' => 'topics#assess_progress_select', as: 'select_to_assess'

  get 'about' => 'static_pages#about'

  resources :users, except: [:destroy] do
    member do
      get :confirm_email
      get :reports
      patch :disable
      patch :enable
    end
  end
  get 're_send_to_confirm_email' => 'users#re_confirm_email'
  post 'signup' => 'users#create_registration'
  get 'user_approval' => 'users#user_registration_approval'
  post 'zone_curator_accept'     => 'users#zone_curator_accept'
  post 'zone_curator_reject'     => 'users#zone_curator_reject'
  get 'my_reports' => 'users#reports', as: 'my_reports'

  resources :zones, only: [:index, :show] do
    member do
      get :reports
      get :load_flm_summary
      get :load_flt_summary
      get :load_language_flm_table
      get :load_board_report
    end
  end
  get 'nation' => 'zones#nation', as: 'nation'
  get 'national_outcomes_chart' => 'zones#national_outcomes_chart', as: 'national_outcomes_chart'
  get 'nation/load_flm_summary' => 'zones#load_flm_summary', as: 'load_national_flm_summary'
  get 'nation/load_flt_summary' => 'zones#load_flt_summary', as: 'load_national_flt_summary'
  get 'nation/load_language_flm_table' => 'zones#load_language_flm_table', as: 'load_national_language_flm_table'
  get 'nation/load_board_report' => 'zones#load_board_report', as: 'load_national_board_report'

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

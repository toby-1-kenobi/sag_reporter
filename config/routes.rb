Rails.application.routes.draw do
  
  
  root 'static_pages#home'

  resources :events do
    get :autocomplete_person_name, :on => :collection
  end
  resources :impact_reports do
    get 'tag', on: :collection
    patch 'tag_update', on: :member
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

  get 'outcomes' => 'topics#assess_progress_select'
  get 'outcomes/:topic_id/:language_id' => 'topics#assess_progress'


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

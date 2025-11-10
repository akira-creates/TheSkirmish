Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  authenticate :user do
    root 'dashboard#index', as: :authenticated_root

    resources :fighters
    resources :weapons

    resources :pools do
      member do
        post :generate_matches
        post :clear_matches
        post :complete
      end
    end

    resources :matches do
      member do
        get :setup
        patch :record_result
        get :display
      end

      resources :penalties, only: [ :create, :destroy ]
    end

      resources :brackets do
      collection do
        # REMOVED: get :new
        # REMOVED: post :create
        # 'resources :brackets' already defines the routes for 'new' and 'create'
        # (GET /brackets/new and POST /brackets).
        # Adding them here was causing the routing conflict.

        # This custom collection route is good.
        post :generate_matches
      end
      member do
        # This custom member route is good.
        # Changed to 'post' as it changes state, but 'patch' is also fine.
        post :record_result
      end
    end
  end

  unauthenticated do
    root 'devise/sessions#new', as: :unauthenticated_root
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

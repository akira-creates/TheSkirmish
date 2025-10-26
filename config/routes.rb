Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  authenticate :user do
    root 'dashboard#index'

  resources :fighters
    resources :pools do
      member do
        post :generate_matches
        post :complete
      end
    end

    resources :matches do
      member do
        get :setup
        patch :record_result
      end
    end

    resources :brackets do
      collection do
        post :generate
      end
      member do
        patch :record_result
      end
    end
  end

  unauthenticated do
    root 'devise/sessions#new'
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

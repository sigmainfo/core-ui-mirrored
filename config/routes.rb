CoreUi::Application.routes.draw do

  namespace :api do
    namespace :auth do
      
      resource :users, only: [:create, :show] do
        collection do
          get "purge"
        end
      end
      
      post   "login" => "sessions#create"
      delete "login/:auth_token" => "sessions#destroy"
    end

    namespace :graph do
      resources :concepts do
        collection do
          post "search"
        end
      end

      resources :terms do
        collection do
          post "search"
        end
      end

      resources :tnodes do
        collection do
          post "search"
        end
      end
    end
  end 

  root to: "repository#show"

  match "*path" => "repository#show"
end

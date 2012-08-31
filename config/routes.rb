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
      resource :concepts do
        post "search"
      end

      resource :terms do
        post "search"
      end
    end
  end 

  root to: "repository#show"

  match "*path" => "repository#show"
end

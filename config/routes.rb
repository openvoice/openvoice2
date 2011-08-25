OpenVoice2::Application.routes.draw do
  resources :endpoints, :only => [:new, :create, :destroy] do
    resources :calls, :only => [:new, :create]
  end

  resources :calls, :only => [:show]

  resources :recordings, :only => [:create]

  resources :accounts
  resources :sessions, :only => [:new, :create, :destroy]

  root :to => 'home#show'
end

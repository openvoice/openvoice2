OpenVoice2::Application.routes.draw do
  resources :endpoints, :only => [:new, :create] do
    resources :calls, :only => [:new, :create, :show]
  end

  resources :accounts
  resources :sessions, :only => [:new, :create, :destroy]

  root :to => 'home#show'
end

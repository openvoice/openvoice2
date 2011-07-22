OpenVoice2::Application.routes.draw do
  resources :accounts
  resources :sessions, :only => [:new, :create]

  root :to => 'home#show'
  resources :dials, :only => [:new, :create]
end

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'moon#index'
  get 'weather', to: 'weather#previsao', as: 'previsao'
  get 'esp32', to: 'esp32#index', as: 'index'
  get 'sea', to: 'sea#previsao2', as: 'previsao2'
end

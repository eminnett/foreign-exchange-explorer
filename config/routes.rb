Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'exchange-rates/:base_currency/:counter_currency/', to: 'exchange_rates#show'
      get 'currencies', to: 'currencies#show'
    end
  end
end

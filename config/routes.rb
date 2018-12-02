# frozen_string_literal: true

Rails.application.routes.draw do
  get 'api/v1/exchange-rates/:base_currency/:counter_currency/', to: 'exchange_rates#show'
  get 'api/v1/currencies', to: 'currencies#show'
  get 'api/v1/dates', to: 'dates#show'

  root to: 'home#index'
end

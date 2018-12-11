# frozen_string_literal: true

class CurrenciesController < ApplicationController
  def show
    currencies = ExchangeRate.currencies
    return not_found if currencies.empty?

    render json: currencies, status: :ok
  rescue StandardError => e
    handle_internal_server_error(e)
  end
end

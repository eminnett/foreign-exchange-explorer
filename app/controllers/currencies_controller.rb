class CurrenciesController < ApplicationController

  def show
    render json: ExchangeRate.currencies
  end
end

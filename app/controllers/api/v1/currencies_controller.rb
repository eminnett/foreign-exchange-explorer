module Api
  module V1
    class CurrenciesController < ApplicationController

      def show
        render json: ExchangeRate.currencies
      end
    end
  end
end

module Api
  module V1
    class DatesController < ApplicationController

      def show
        render json: ExchangeRate.dates
      end
    end
  end
end

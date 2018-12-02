# frozen_string_literal: true

class DatesController < ApplicationController
  def show
    render json: ExchangeRate.dates
  end
end

# frozen_string_literal: true

class DatesController < ApplicationController
  def show
    dates = ExchangeRate.dates
    return not_found if dates.empty?

    render json: dates, status: :ok
  rescue StandardError => e
    handle_internal_server_error(e)
  end
end

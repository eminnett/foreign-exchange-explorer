# frozen_string_literal: true

class ExchangeRatesController < ApplicationController
  def show
    base_currency = exchange_rate_params[:base_currency]
    counter_currency = exchange_rate_params[:counter_currency]
    on = exchange_rate_params[:on]
    # Default to the range between today and 90 days ago.
    from = exchange_rate_params[:from] || Time.zone.today - 90.days
    to = exchange_rate_params[:to] || Time.zone.today

    # Since there are defaults for 'from' and 'to',
    # providing 'on' trumps these defaults.
    if on
      begin
        response = ExchangeRate.find_rate(on, base_currency, counter_currency)
      rescue ExchangeRate::NotFound => e
        response = {error: e.message}
      end
    elsif from && to
      response = begin
        if from > to
          {error: "The 'from' date must be older than the 'to' date."}
        else
          ExchangeRate.rates_between(from, to, base_currency, counter_currency)
        end
      end
    end
    render json: response
  end

  private

  def exchange_rate_params
    currencies = %i[base_currency counter_currency]
    dates = %i[on from to]
    permitted_params = params.permit(*(currencies + dates))
    dates.each do |param|
      permitted_params[param] = (
        permitted_params[param].present? ?
          Date.parse(permitted_params[param]) :
          nil
      )
    end
    permitted_params
  end
end

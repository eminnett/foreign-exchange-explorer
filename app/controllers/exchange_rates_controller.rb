# frozen_string_literal: true

class ExchangeRatesController < ApplicationController
  CURRENCY_PARAMS = %i[base_currency counter_currency].freeze
  DATE_PARAMS = %i[on from to].freeze

  attr_accessor(*(CURRENCY_PARAMS + DATE_PARAMS))

  def show
    assign_params parse_params
    assign_defaults
    render json: build_response
  end

  private

  def parse_params
    permitted_params = params.permit(*(CURRENCY_PARAMS + DATE_PARAMS))
    DATE_PARAMS.each do |date_param|
      date = permitted_params[date_param]
      permitted_params[date_param] = Date.parse(date) if date.present?
    end
    permitted_params
  end

  def assign_params(permitted_params)
    (CURRENCY_PARAMS + DATE_PARAMS).each do |p|
      instance_variable_set("@#{p}", permitted_params[p])
    end
  end

  def assign_defaults
    @from = from || Time.zone.today - 90.days
    @to = to || Time.zone.today
  end

  def build_response
    # Since there are defaults for 'from' and 'to', providing 'on' trumps these defaults.
    return single_exchange_rate if on.present?

    multiple_exchange_rates
  end

  def single_exchange_rate
    ExchangeRate.find_rate(on, base_currency, counter_currency)
  rescue ExchangeRate::NotFound => e
    {error: e.message}
  end

  def multiple_exchange_rates
    return {error: "The 'from' date must be older than the 'to' date."} if from > to

    ExchangeRate.rates_between(from, to, base_currency, counter_currency)
  end
end

# frozen_string_literal: true

require "httparty"

module Importers
  # Each source of data would have its own importer class. As long as the
  # importer interfaces with ExchangeRate.set() they will be interchangeable.
  class EuropeanCentralBank
    SOURCE = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"

    def initialize(options={})
      @rates_counter = 0
      @days_counter = 0
      @latest_n_days = options[:latest_n_days] || 365
      @silent = options[:silent] || false
      @calculate_combinations = options[:calculate_combinations] || false
      # The inverse rate is part of the set of combinations so the
      # option can be set implicitly.
      @calculate_inverse = @calculate_combinations || options[:calculate_inverse] || false
    end

    def settings
      {
        latest_n_days:          @latest_n_days,
        silent:                 @silent,
        calculate_combinations: @calculate_combinations,
        calculate_inverse:      @calculate_inverse
      }
    end

    def import_exchange_rates
      time { process_exchange_rates(request_data) }
    end

    def time
      start = Time.zone.now
      yield
      ellapsed_minutes = (Time.zone.now - start) * 24.0 * 60.0
      log "\nProcess took #{ellapsed_minutes.round(2)} minutes to complete."
    end

    def request_data
      xml_data = HTTParty.get(self.class::SOURCE).body
      # TODO: Raise an error if the response is not in the expected format.
      Hash.from_xml(xml_data)["Envelope"]["Cube"]["Cube"]
    end

    def process_exchange_rates(data)
      data.each do |data_for_day|
        break if @latest_n_days == @days_counter

        process_day_of_data(data_for_day)
        @days_counter += 1
      end
      log "\nImported #{@days_counter} days of data. #{@rates_counter} exchange rates set."
      @counter = 0
    end

    def set_rate(date, base_currency, counter_currency, value)
      ExchangeRate.set(date, base_currency, counter_currency, value)
      @rates_counter += 1
      log_increment "."
    end

    def process_day_of_data(data_for_day)
      base_currency = "EUR"
      date = Date.parse(data_for_day["time"])
      day_data = data_for_day["Cube"]

      day_data.each do |datum|
        set_rate(date, base_currency, datum["currency"], datum["rate"])
        process_inverse(date, base_currency, datum) if @calculate_inverse
      end

      # NB: Beware, this is a very expensive operation!
      process_combinations!(date, day_data) if @calculate_combinations
    end

    def process_inverse(date, base_currency, datum)
      inverse_rate = 1 / datum["rate"].to_f
      set_rate(date, datum["currency"], base_currency, inverse_rate)
    end

    def process_combinations!(date, day_data)
      combinations = calculate_combinations!(day_data)
      combinations.each do |datum|
        set_rate(
          date,
          datum[:base_currency],
          datum[:counter_currency],
          datum[:rate]
        )
      end
    end

    def calculate_combinations!(data)
      return [] unless data.count > 1 # No combinations to calculate.

      base_rate = data.slice!(0)
      calculate_pairs(base_rate, data).flatten + calculate_combinations!(data)
    end

    private

    def calculate_pairs(base_rate, data)
      data.map do |datum|
        [
          {
            base_currency:    base_rate["currency"],
            counter_currency: datum["currency"],
            rate:             datum["rate"].to_f / base_rate["rate"].to_f
          },
          {
            base_currency:    datum["currency"],
            counter_currency: base_rate["currency"],
            rate:             base_rate["rate"].to_f / datum["rate"].to_f
          }
        ]
      end
    end

    def log_increment(message)
      Rails.logger << message unless @silent
    end

    def log(message)
      Rails.logger.info(message) unless @silent
    end
  end
end

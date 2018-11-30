class ExchangeRateJob
  include Sidekiq::Worker

  def perform(options = {})
    source = options[:source] || :ECB
    case source
    when :ECB
      Importers::EuropeanCentralBank.new({
        latest_n_days: 1,
        calculate_combinations: true
      }).import_exchange_rates
    else
      raise "The ExchangeRateJob does not know how " \
        "to handle source #{source}."
    end
  end
end

class ExchangeRateJob
  include Sidekiq::Worker

  def perform(options = {})
    source = options[:source] || :ECB
    case source
    when :ECB
      importer = Importers::EuropeanCentralBank.new({
        test_execution: true,
        calculate_combinations: true
      })
      importer.import_exchange_rates
    else
      raise "The ExchangeRateJob does not know how " \
        "to handle source #{source}."
    end
  end
end

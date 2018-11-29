class ExchangeRate
  def self.repository
    @repository ||= ExchangeRateRepository.new
  end

  def self.currency_repository
    @currency_repository ||= CurrencyRepository.new
  end

  def self.currencies
    currency_repository.all.to_a.uniq { |c| c.code }
  end

  def self.set(date, base_currency, counter_currency, value)
    exchange_rate = Rate.new(
      date: date,
      base_currency: base_currency,
      counter_currency: counter_currency,
      value: value
    )
    [base_currency, counter_currency].each { |c| currency_repository.store_unique(c) }
    existing_rate = repository.exact_match(date, base_currency, counter_currency).first
    return existing_rate if existing_rate.present?
    repository.save(exchange_rate)
    exchange_rate
  end

  def self.find_rate(date, base_currency, counter_currency)
    rate = repository.exact_match(date, base_currency, counter_currency).first
    unless rate.present?
      raise "#{base_currency} in #{counter_currency} on #{date} is unknown."
    end
    rate
  end

  # TODO: Make this more efficient by searching for a range of rates in Elasticsearch
  def self.rates_between(from, to, base_currency, counter_currency)
    (from..to).map do |day|
      unless day.saturday? || day.sunday?
        find_rate(day, base_currency, counter_currency)
      end
    end.compact
  end

  def self.at(date, base_currency, counter_currency)
    find_rate(date, base_currency, counter_currency).value
  end

  def self.between(from, to, base_currency, counter_currency)
    rates = rates_between(from, to, base_currency, counter_currency)
    rates.each_with_object({}) { |r, hash| hash[r.date] = r.value }
  end
end

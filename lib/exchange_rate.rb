class ExchangeRate
  class NotFound < StandardError; end

  def self.repository
    @repository ||= ExchangeRateRepository.new
  end

  def self.currency_repository
    @currency_repository ||= CurrencyRepository.new
  end

  def self.dates
    # TODO: Refactor this not to use a lookup of 'EUR' rates as proxy for dates.
    repository.all_eur.to_a.map{|rate| rate.date}.uniq
  end

  def self.currencies
    currency_repository.all.to_a.uniq { |c| c.code }.sort_by(&:code)
  end

  def self.set(date, base_currency, counter_currency, value)
    exchange_rate = Rate.new(
      date: date,
      base_currency: base_currency,
      counter_currency: counter_currency,
      value: value.to_s
    )
    existing_rate = repository.exact_match(date, base_currency, counter_currency).first
    return existing_rate if existing_rate.present?
    [base_currency, counter_currency].each { |c| currency_repository.store_unique(c) }
    repository.save(exchange_rate)
    exchange_rate
  end

  def self.find_rate(date, base_currency, counter_currency)
    rate = repository.exact_match(date, base_currency, counter_currency).first
    unless rate.present?
      raise NotFound, "The exchange rate for #{base_currency} in " \
        "#{counter_currency} on #{date} is unknown."
    end
    rate
  end

  def self.rates_between(from, to, base_currency, counter_currency)
    repository.between_dates(from, to, base_currency, counter_currency).to_a
  end

  def self.at(date, base_currency, counter_currency)
    find_rate(date, base_currency, counter_currency).value
  end

  def self.between(from, to, base_currency, counter_currency)
    rates = rates_between(from, to, base_currency, counter_currency)
    rates.each_with_object({}) { |r, hash| hash[r.date] = r.value }
  end
end

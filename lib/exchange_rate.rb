class ExchangeRate
  def self.repository
    @repository ||= ExchangeRateRepository.new
  end

  def self.set(date, base_currency, counter_currency, value)
    exchange_rate = Rate.new(
      date: date,
      base_currency: base_currency,
      counter_currency: counter_currency,
      value: value
    )
    existing_rate = repository.exact_match(exchange_rate).first
    return existing_rate if existing_rate.present?
    repository.save(exchange_rate)
    exchange_rate
  end
end

# frozen_string_literal: true

class ExchangeRate
  class NotFound < StandardError; end

  def self.repository
    @repository ||= begin
      repo = ExchangeRateRepository.new
      repo.create_index! unless repo.index_exists?
      repo
    end
  end

  def self.currency_repository
    @currency_repository ||= begin
      repo = CurrencyRepository.new
      repo.create_index! unless repo.index_exists?
      repo
    end
  end

  def self.dates
    repository.all_dates.to_a.map(&:date).uniq
  end

  def self.currencies
    currency_repository.all.to_a.uniq(&:code).sort_by(&:code)
  end

  def self.set(date, base_currency, counter_currency, value)
    exchange_rate = Rate.new(
      date:             date,
      base_currency:    base_currency,
      counter_currency: counter_currency,
      value:            value.to_s
    )
    existing_rate = repository.exact_match(
      date, base_currency, counter_currency
    )
    return existing_rate if existing_rate.present?

    [base_currency, counter_currency].each do |c|
      currency_repository.store_unique(c)
    end
    repository.save(exchange_rate)
    exchange_rate
  end

  def self.find_rate(date, base_currency, counter_currency)
    rate = repository.exact_match(date, base_currency, counter_currency)
    return rate if rate.present?

    inverse_rate = find_rate_by_inverse(date, base_currency, counter_currency)
    return inverse_rate if inverse_rate.present?

    combination_rate = find_rate_through_combination(date, base_currency, counter_currency)
    return combination_rate if combination_rate.present?

    raise NotFound, "The exchange rate for #{base_currency} in " \
      "#{counter_currency} on #{date} is unknown."
  end

  def self.rates_between(from, to, base_currency, counter_currency)
    stored_rates = repository.between_dates(from, to, base_currency, counter_currency).to_a
    dates_in_range = available_dates_in_range(from, to)
    return stored_rates if stored_rates.map(&:date) == dates_in_range

    # Fill in the blanks using `.find_rate` which will try and calculate the missing rates.
    rates = stored_rates
    (dates_in_range - stored_rates.map(&:date)).each do |date|
      begin # rubocop:disable Style/RedundantBegin
        rates << find_rate(date, base_currency, counter_currency)
      rescue NotFound
        # Ignore rates that can't be found or calculated.
        next
      end
    end
    rates.sort_by!(&:date)
  end

  def self.at(date, base_currency, counter_currency)
    find_rate(date, base_currency, counter_currency).value
  end

  def self.between(from, to, base_currency, counter_currency)
    rates = rates_between(from, to, base_currency, counter_currency)
    rates.each_with_object({}) {|r, hash| hash[r.date] = r.value }
  end

  def self.find_rate_by_inverse(date, base_currency, counter_currency)
    inverse_rate = repository.exact_match(date, counter_currency, base_currency)
    return if inverse_rate.blank?

    set(date, base_currency, counter_currency, 1 / inverse_rate.value.to_f)
  end
  private_class_method :find_rate_by_inverse

  def self.find_rate_through_combination(date, base_currency, counter_currency)
    common_currency = repository.most_common_base_currency
    base_rate = repository.exact_match(date, common_currency, base_currency)
    counter_rate = repository.exact_match(date, common_currency, counter_currency)
    return unless base_rate.present? && counter_rate.present?

    value = counter_rate.value.to_f / base_rate.value.to_f
    set(date, base_currency, counter_currency, value)
  end
  private_class_method :find_rate_through_combination

  def self.available_dates_in_range(from, to)
    available_dates = dates # Save this so we only make one call to the repository.
    from_index = available_dates.index(from.to_s) || 0
    to_index = available_dates.index(to.to_s) || available_dates.count - 1
    available_dates.slice(from_index..to_index)
  end
  private_class_method :available_dates_in_range
end

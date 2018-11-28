require 'elasticsearch/persistence'
class ExchangeRateRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name "#{Rails.env}_exchange_rates"
  klass Rate

  mapping do
    indexes :id
    indexes :base_currency
    indexes :counter_currency
    indexes :date
  end

  def all(options = {})
    return [] unless index_exists?
    search({ query: { match_all: { } } },
           { sort: 'date' }.merge(options))
  end

  def exact_match(date, base_currency, counter_currency)
    return [] unless index_exists?
    search(query: {
      bool: {
        must: [
          { match: { base_currency: base_currency }},
          { match: { counter_currency: counter_currency }},
          { match: { date: date }}
        ]
      }
    })
  end

  # TODO: Add search method that looks up rates in a date range.
end

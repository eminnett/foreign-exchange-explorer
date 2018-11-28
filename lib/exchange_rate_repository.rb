require 'elasticsearch/persistence'
class ExchangeRateRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'exchange_rates'
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

  def exact_match(rate)
    return [] unless index_exists?
    search(query: {
      bool: {
        must: [
          { match: { base_currency: rate.base_currency }},
          { match: { counter_currency: rate.counter_currency }},
          { match: { date: rate.date }}
        ]
      }
    })
  end
end

# frozen_string_literal: true

require "elasticsearch/persistence"
class ExchangeRateRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name "#{Rails.env}_exchange_rates"
  klass Rate

  mapping do
    indexes :id
    indexes :base_currency,    type: "keyword"
    indexes :counter_currency, type: "keyword"
    indexes :date,             type: "date"
  end

  def all(options={})
    search({from: 0, size: 10_000, query: {match_all: {}}},
           {sort: "date"}.merge(options))
  end

  def most_common_base_currency
    search(size: 0, aggs: {currencies: {terms: {field: :base_currency}}})
      .response.aggregations.currencies.buckets.first[:key]
  end

  def all_dates
    search(
      {
        from: 0, size: 10_000, query: {
          match: {base_currency: most_common_base_currency}
        }
      },
      sort: "date"
    )
  end

  def exact_match(date, base_currency, counter_currency)
    search(query: {
             bool: {
               must: [
                 {match: {base_currency: base_currency}},
                 {match: {counter_currency: counter_currency}},
                 {match: {date: date}}
               ]
             }
           }).first
  end

  def between_dates(from, to, base_currency, counter_currency)
    search({from: 0, size: 10_000, query: {
             bool: {
               must: [
                 {match: {base_currency: base_currency}},
                 {match: {counter_currency: counter_currency}},
                 {range: {date: {gte: from, lte: to}}}
               ]
             }
           }}, sort: "date")
  end
end

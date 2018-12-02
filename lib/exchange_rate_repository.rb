# frozen_string_literal: true

require "elasticsearch/persistence"
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

  def all(options={})
    return [] unless index_exists?

    search({from: 0, size: 10_000, query: {match_all: {}}},
           {sort: "date"}.merge(options))
  end

  def all_eur
    return [] unless index_exists?

    search(
      {from: 0, size: 10_000, query: {match: {base_currency: "EUR"}}},
      sort: "date"
    )
  end

  def exact_match(date, base_currency, counter_currency)
    return [] unless index_exists?

    search(query: {
             bool: {
               must: [
                 {match: {base_currency: base_currency}},
                 {match: {counter_currency: counter_currency}},
                 {match: {date: date}}
               ]
             }
           })
  end

  def between_dates(from, to, base_currency, counter_currency)
    return [] unless index_exists?

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

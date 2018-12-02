# frozen_string_literal: true

require "elasticsearch/persistence"
class CurrencyRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name "#{Rails.env}_currencies"
  klass Currency

  mapping do
    indexes :code
  end

  def all(options={})
    return [] unless index_exists?

    search({from: 0, size: 100, query: {match_all: {}}}.merge(options))
  end

  def store_unique(code)
    matches = index_exists? ? search(query: {match: {code: code}}) : nil
    save(Currency.new(code: code)) if !index_exists? || matches.count.zero?
    # Delete duplicates caused by the NRT nature of Elasticsearch.
    return unless matches && matches.count > 1
    matches.each_with_index do |currency, i|
      delete(currency, ignore: 404) if i.positive?
    end
  end
end

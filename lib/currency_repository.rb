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
    search({from: 0, size: 100, query: {match_all: {}}}.merge(options))
  end

  def store_unique(code)
    matches = search(query: {match: {code: code}})
    save(Currency.new(code: code)) if matches.count.zero?
    # Delete duplicates caused by the NRT nature of Elasticsearch.
    remove_duplicates(matches)
  end

  private

  def remove_duplicates(matches)
    return unless matches && matches.count > 1

    matches.each_with_index do |currency, i|
      delete(currency, ignore: 404) if i.positive?
    end
  end
end

# frozen_string_literal: true

namespace :elasticsearch do
  desc "Remove all project data from the Elasticsearch index"
  task :remove_data do
    index = "#{Rails.env}_exchange_rates"
    `curl --silent --output /dev/null -XDELETE localhost:9200/#{index}`
    puts "Removed all exchange rates in #{index}."
    index = "#{Rails.env}_currencies"
    `curl --silent --output /dev/null -XDELETE localhost:9200/#{index}`
    puts "Removed all currencies in #{index}."
  end
end

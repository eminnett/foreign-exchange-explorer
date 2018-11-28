namespace :elasticsearch do
  desc 'Remove all exchange_rates in the Elasticsearch index'
  task :delete_all_exchange_rates do
    index = "#{Rails.env}_exchange_rates"
    `curl --silent --output /dev/null -XDELETE localhost:9200/#{index}`
    puts "Removed all exchange rates in #{index}."
  end
end

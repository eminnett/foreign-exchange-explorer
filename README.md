# Foreign Exchange Explorer

### Description

### Dependencies

* [Git](https://git-scm.com/downloads)
* [Ruby 2.5.3](https://www.ruby-lang.org/en/)
* [Rails 5.2.1](http://rubyonrails.org/)
* [Elasticsearch 6.5](https://www.elastic.co/products/elasticsearch)

#### For Asynchronous Jobs
* [Redis](https://redislabs.com/)

### Setup

- `bundle install`
- Start Elasticsearch. The method of starting Elasticsearch depends upon how you installed it and whether you want to run it as a daemon or not.
- `bundle exec rails s`

#### For Asynchronous Jobs

**NB:** I recommend reviewing `/lib/tasks/jobs.rake` before executing these commands on your machine.

- `redis-server`
This will schedule the import job to run daily at 1AM and initialise Sidekiq.
- `bundle exec rake jobs:initialise`

To stop the job worker and clear the schedule:
- `bundle exec rake jobs:teardown`


### Populating the Data Store

There are a few options for populating Elasticsearch with exchange rate data.

- `bundle exec rake db:seed` This will add a set of sample data covering 6 days of exchange rates all with 'EUR' as the base currency.

These are the results of running the ECB importer with various options in the Rails console. The Elasticsearch index was cleared between each execution.
- `Importers::EuropeanCentralBank.new.import_exchange_rates` Standard import: 2.35 minutes (2,048 exchange rates)
- `Importers::EuropeanCentralBank.new({calculate_inverse: true}).import_exchange_rates` Import with inverse calculations: 2.66 minutes (4,096 exchange rates)
- `Importers::EuropeanCentralBank.new({calculate_combinations: true}).import_exchange_rates` Import with all combinations: 53.28 minutes (67,584 exchange rates)
- `Importers::EuropeanCentralBank.new({latest_n_days: 1, calculate_combinations: true}).import_exchange_rates` Same setting as the nightly job (all combinations but only 1 day of new data): 0.73 minutes (1,056 exchange rates)

If you fork this project and explore it locally, I recommend importing 10 days of data with all combinations. This will provide sufficient data to play with the client-side application and API without encountering too much missing exchange rate data. On my computer, this took 7.41 minutes to complete and imported 10,560 exchange rates.
```ruby
Importers::EuropeanCentralBank.new({
  latest_n_days: 10,
  calculate_combinations: true
}).import_exchange_rates
```

Execute this to remove the Elasticsearch indices used by this project:
`bundle exec rake elasticsearch:remove_data`

### Running the Automated Tests

- `bundle exec rake`

### Services

### Room for improvement

- Decouple Elasticsearch from the automated tests.
- Refactor the date look up logic so it doesn't rely upon searching for 'EUR' rates.
- Automated tests exercising the React application.

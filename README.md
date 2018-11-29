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
- Start Elasticsearch. The method of starting Elasticsearch depends how you installed it and whether you want to run it as a daemon or not.
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

- `bundle exec rake db:seed` This will add a small set of

- Standard import: 2.35 minutes (2048 exchange rates)
- Import with inverse calculations: 2.66 minutes (4096 exchange rates)
- Import with all combinations: 53.28 minutes (67584 exchange rates)
- Simulation of nightly job (all combinations but only 1 day of new data):

Remove Elasticsearch indices: `bundle exec rake elasticsearch:remove_data`

### Running the Automated Tests

- `bundle exec rake`

### Services

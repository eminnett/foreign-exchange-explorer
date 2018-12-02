# frozen_string_literal: true

job_type :sidekiq, 'cd :path && :environment_variable=:environment ' \
  'bundle exec sidekiq-client push :task :output'

every 1.day, at: ['1:00 am'], roles: [:app] do
  sidekiq 'ExchangeRateJob'
end

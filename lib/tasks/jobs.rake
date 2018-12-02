# frozen_string_literal: true

namespace :jobs do
  desc "Setup the job worker and scheduler"
  task :initialise do
    `whenever --update-crontab`
    puts "Crontab updated."
    `bundle exec sidekiq -d -L log/sidekiq.log`
    puts "Sidekiq initialised."
  end

  desc "Stop the job worker and remove the cron jobs"
  task :teardown do
    `whenever --clear-crontab`
    puts "Tasks removed from Crontab."
    cmd = "ps -axf | grep 'sidekiq.*foreign-exchange-explorer' | " \
      "grep -v grep | awk '{print \"kill -9 \" $2}' | sh"
    `#{cmd}`
    puts "Sidekiq stopped."
  end
end

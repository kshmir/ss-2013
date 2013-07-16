web:    bundle exec rails s
db:     redis-server
scheduler: bundle exec rake resque:scheduler
worker: bundle exec rake resque:work QUEUE=* COUNT=4

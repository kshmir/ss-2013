export R_HOME=/Library/Frameworks/R.framework/Resources;
redis-server
COUNT=1 QUEUE=* rake resque:workers
rails s


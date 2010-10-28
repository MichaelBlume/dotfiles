#!/bin/sh 
#tail -f /var/log/loggly/exception /var/log/loggly/loggly /var/log/loggly/cron |  perl -pe 's/ERROR|CRIT/\e[1;31;43m$&\e[0m/g'
tail -f /var/log/loggly/exception /var/log/loggly/loggly /var/log/loggly/cron 

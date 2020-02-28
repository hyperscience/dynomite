#!/bin/bash
set -x

# the idea for this script is taken from here
# https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86

redis_pid=0
dynomite_pid=0

sig_term_handler() {
    if [ "$redis_pid" != "0" ]; then
        kill -SIGTERM "$redis_pid"
        wait "$redis_pid"
    fi
    if [ "$dynomite_pid" != "0" ]; then
        kill -SIGTERM "$dynomite_pid"
        wait "$dynomite_pid"
    fi
}

# killing the fail -f /dev/null first
# then calling our handler
trap 'kill ${!}; sig_term_handler' SIGTERM

redis-server /etc/redis/redis.conf &
redis_pid="$!"

src/dynomite --conf-file=conf/redis_single.yml -v5 &
dynomite_pid="$!"

tail -f /dev/null &
wait ${!}

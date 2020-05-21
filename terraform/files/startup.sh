#!/bin/bash

adduser --group hab
useradd -g hab hab

curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
hab license accept

nohup hab sup run 2>&1 > /var/log/sup.log &

while ! hab sup status 2> /dev/null; do
  echo "waiting for supervisor to come online"
  sleep 1
done

hab svc load core/redis
hab svc load afiune/go-redis-reader --bind cache:redis.default
mkdir -p /hab/user/redis/config/
echo 'protected-mode = "no"' > /hab/user/redis/config/user.toml

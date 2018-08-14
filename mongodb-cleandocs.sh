#!/bin/bash

# Settings
DB_HOST="$MONGO_HOST"
DB_NAME="$MONGO_DATABASE"
DB_USER="$MONGO_USER"
DB_PASS="$MONGO_PASS"
PD_TOKEN="$PAGERDUTY_TOKEN"

# Connect to mongo
mongo --quiet -u "$DB_USER" -p "$DB_PASS" -h "$DB_HOST" || curl -X POST --header ‘Content-Type: application/json' --header 'Accept: application/vnd.pagerduty+json;version=2' --header 'From: admin@idecisiongames.com' --header 'Authorization: Token token="$PD_TOKEN"' -d '{"incident":{"type":"incident","title":"[Clean docs] Couldn't connect to db.","service":{"id":"PONW4BQ","type":"service_reference"}}}' 'https://api.pagerduty.com/incidents'

# Switch to idg
use "$DB_NAME"

# Clean ops
db.getCollectionNames().forEach(function (c) {if(c.indexOf('o_') < 0) return; db[c].remove(({'m.ts': {'$lt': new Date().getTime() - 7 * 24 * 60 * 60 * 1000}}));}) || curl -X POST --header ‘Content-Type: application/json' --header 'Accept: application/vnd.pagerduty+json;version=2' --header 'From: admin@idecisiongames.com' --header 'Authorization: Token token="$PD_TOKEN"' -d '{"incident":{"type":"incident","title":"IDG ops cleaning failed.","service":{"id":"PONW4BQ","type":"service_reference"}}}' 'https://api.pagerduty.com/incidents'

# Clean tasks
db.tasks.remove(({'createdAt': {'$lt': new Date().getTime() - 24 * 60 * 60 * 1000}})) || curl -X POST --header ‘Content-Type: application/json' --header 'Accept: application/vnd.pagerduty+json;version=2' --header 'From: admin@idecisiongames.com' --header 'Authorization: Token token="$PD_TOKEN"' -d '{"incident":{"type":"incident","title":"IDG tasks cleaning failed.","service":{"id":"PONW4BQ","type":"service_reference"}}}' 'https://api.pagerduty.com/incidents'
db.o_tasks.remove(({'m.ts': {'$lt': new Date().getTime() - 24 * 60 * 60 * 1000}})) || curl -X POST --header ‘Content-Type: application/json' --header 'Accept: application/vnd.pagerduty+json;version=2' --header 'From: admin@idecisiongames.com' --header 'Authorization: Token token="$PD_TOKEN"' -d '{"incident":{"type":"incident","title":"IDG tasks ops cleaning failed.","service":{"id":"PONW4BQ","type":"service_reference"}}}' 'https://api.pagerduty.com/incidents'

exit
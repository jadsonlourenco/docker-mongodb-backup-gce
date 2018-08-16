#!/bin/bash

# Settings
DB_HOST="$MONGO_HOST"
DB_NAME="$MONGO_DATABASE"
DB_USER="$MONGO_USER"
DB_PASS="$MONGO_PASS"
PD_TOKEN="$PAGERDUTY_TOKEN"
PD_SERVICE="$PAGERDUTY_SERVICE"

get_post_data()
{
  cat <<EOF
{"incident":{"type":"incident","title":"$1","service":{"id":"$PD_SERVICE","type":"service_reference"}}}
EOF
}

send_notification()
{
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/vnd.pagerduty+json;version=2' --header 'From: admin@idecisiongames.com' --header "Authorization: Token token=$PD_TOKEN" -d "$(get_post_data "$1")" 'https://api.pagerduty.com/incidents'
}

# Connect to mongo
mongo --quiet -u "$DB_USER" -p "$DB_PASS" -h "$DB_HOST" || send_notification [IDG Clean Docs] Couldn't Connect to DB.

# Switch to idg
use "$DB_NAME"

# Clean ops
db.getCollectionNames().forEach(function (c) {if(c.indexOf('o_') < 0) return; db[c].remove(({'m.ts': {'$lt': new Date().getTime() - 7 * 24 * 60 * 60 * 1000}}));}) || send_notification IDG Ops Cleaning Failed

# Clean tasks
db.tasks.remove(({'createdAt': {'$lt': new Date().getTime() - 24 * 60 * 60 * 1000}})) || send_notification IDG Tasks Cleaning Failed.
db.o_tasks.remove(({'m.ts': {'$lt': new Date().getTime() - 24 * 60 * 60 * 1000}})) || send_notification IDG Tasks Ops Cleaning Failed.

exit
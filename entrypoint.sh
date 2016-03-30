#!/bin/bash
set -m

TIME="$CRON_TIME"
DATABASE="$MONGO_DATABASE"
gs_project_id="$PROJECT_ID"
gs_access_key_id="$GS_ID"
gs_secret_access_key="$GS_SECRET"

# Create boto config file
cat <<EOF > /etc/boto.cfg
[Credentials]
gs_access_key_id = $gs_access_key_id
gs_secret_access_key = $gs_secret_access_key
[Boto]
https_validate_certificates = True
[GSUtil]
content_language = en
default_api_version = 1
default_project_id = $gs_project_id
EOF

echo "$TIME /mongodb-backup.sh" > /cron/"$DATABASE"
devcron.py /cron/"$DATABASE"

fg

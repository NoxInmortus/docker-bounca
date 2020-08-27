#!/usr/bin/env bash
set -euo pipefail
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
INI_FILE=${DOCROOT}/etc/bounca/main.ini

# uwsgi
/etc/init.d/uwsgi restart

## Setup main.ini
if [[ ! -f ${INI_FILE} ]]; then
  cp -v /var/www/default/main.ini ${INI_FILE}
fi

sed -i "s/DB_USER/${DB_USER}/g" ${INI_FILE}
sed -i "s/DB_PWD/${DB_PWD}/g" ${INI_FILE}
sed -i "s/DB_HOST/${DB_HOST}/g" ${INI_FILE}
sed -i "s/DB_NAME/${DB_NAME}/g" ${INI_FILE}
sed -i "s/SMTP_HOST/${SMTP_HOST}/g" ${INI_FILE}
sed -i "s/ADMIN_MAIL/${ADMIN_MAIL}/g" ${INI_FILE}
sed -i "s/FROM_MAIL/${FROM_MAIL}/g" ${INI_FILE}

echo "psql:
  dbname: ${DB_NAME}
  username: ${DB_USER}
  password: ${DB_PWD}
  host: ${DB_HOST}
  port: 5432

django:
  debug: True
  secret_key: 'pleasechangemeimsecret'
  hosts:
    - localhost
    - 127.0.0.1

mail:
  host: ${SMTP_HOST}
  admin: ${ADMIN_MAIL}
  from: ${FROM_MAIL}" > ${DOCROOT}/etc/bounca/services.yaml

# Initial setup only
if [[ -f ${DOCROOT}/init-setup ]]; then
  # collect static files
  python3 ${DOCROOT}/manage.py collectstatic --noinput
  # create the database
  python3 ${DOCROOT}/manage.py migrate --noinput
  rm -v ${DOCROOT}/init-setup
fi

# Check Nginx config
nginx -t

exec "$@"

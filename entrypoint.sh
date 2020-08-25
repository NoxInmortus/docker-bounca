#!/usr/bin/env bash
set -euo pipefail
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin

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

# Initial setup only
if [[ -f /etc/bounca/init-setup ]]; then
  # collect static files
  python3 ${DOCROOT}/manage.py collectstatic --noinput
  # create the database
  python3 ${DOCROOT}/manage.py migrate --noinput
  rm -v /etc/bounca/init-setup
fi

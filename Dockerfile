#-----------------------------#
# Dockerfile BounCA           #
# By NoxInmortus              #
#-----------------------------#

FROM debian:buster-slim
LABEL maintainer='NoxInmortus'

ENV BOUNCA_SRC=bounca \
    DOCROOT=/var/www/bounca \
    INI_FILE=/etc/bounca/main.ini \
    DB_USER=postgres \
    DB_PWD=postgres \
    DB_HOST=postgres \
    DB_NAME=postgres \
    SMTP_HOST=localhost \
    ADMIN_MAIL=admin@localhost \
    FROM_MAIL=no-reply@localhost

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -qy nginx ca-certificates python3 python3-dev python3-setuptools python3-pip git gcc libpq-dev \
  && git clone --single-branch https://github.com/repleo/bounca.git ${DOCROOT} \
  && mkdir -pv ${DOCROOT}/media ${DOCROOT}/static ${DOCROOT}/logs /etc/bounca /var/www/bounca/bounca/static /var/www/default \
  && pip3 install wheel uwsgi \
  && pip3 install -r ${DOCROOT}/requirements.txt

COPY entrypoint.sh main.ini uwsgi.conf vhost.conf /var/www/default/

RUN cp -v /var/www/default/main.ini ${INI_FILE} \
  && cp -v /var/www/default/uwsgi.conf /etc/nginx/conf.d/uwsgi.conf \
  && cp -v /var/www/default/vhost.conf /etc/nginx/sites-enabled/default \
  && chmod +x /var/www/default/entrypoint.sh \
  && touch /etc/bounca/init-setup

VOLUME /var/www/bounca /etc/bounca

ENTRYPOINT ["/var/www/default/entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

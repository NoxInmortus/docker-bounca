#-----------------------------#
# Dockerfile BounCA           #
# By NoxInmortus              #
#-----------------------------#

FROM debian:buster-slim
LABEL maintainer='NoxInmortus'

ENV BOUNCA_SRC=bounca \
    DOCROOT=/var/www/bounca \
    DB_USER=postgres \
    DB_PWD=postgres \
    DB_HOST=postgres \
    DB_NAME=postgres \
    SMTP_HOST=localhost \
    ADMIN_MAIL=admin@localhost \
    FROM_MAIL=no-reply@localhost

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -qy nginx ca-certificates python3 python3-dev python3-setuptools python3-pip \
    git gcc libpq-dev libffi-dev uwsgi uwsgi-plugin-python3 \
  && git clone --single-branch https://github.com/repleo/bounca.git ${DOCROOT} \
  && mkdir -pv ${DOCROOT}/media ${DOCROOT}/static ${DOCROOT}/logs /etc/bounca /var/www/bounca/bounca/static /var/www/default \
  && pip3 install wheel \
  && pip3 install -r ${DOCROOT}/requirements.txt

COPY entrypoint.sh main.ini uwsgi.ini vhost.conf /var/www/default/

RUN cp -v /var/www/default/main.ini ${DOCROOT}/etc/bounca/main.ini \
  && cp -v /var/www/default/uwsgi.ini /etc/uwsgi/apps-available/bounca.ini \
  && ln -s /etc/uwsgi/apps-available/bounca.ini /etc/uwsgi/apps-enabled/bounca.ini \
  && cp -v /var/www/default/vhost.conf /etc/nginx/sites-enabled/default \
  && chmod +x /var/www/default/entrypoint.sh \
  && chown -R www-data:www-data /var/www/bounca \
  && touch ${DOCROOT}/init-setup \
  && apt-get remove --purge -qy git ca-certificates && apt-get autoremove -qy \
  && apt-get clean \
  && rm -rfv /tmp/* /var/tmp/* /var/lib/apt/lists/* \
  ;

VOLUME /var/www/bounca

ENTRYPOINT ["/var/www/default/entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

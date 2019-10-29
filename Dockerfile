FROM php:7.2-apache

ENV SSP_PACKAGE 1.3

# Install the software that ssp environment requires
RUN apt-get update \
    && apt-get install -y libcurl4-gnutls-dev libxml2 libxml2-dev zip unzip libmcrypt-dev libldap2-dev  sendmail-bin --no-install-recommends \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap curl json mbstring simplexml xml \
    && rm -rf /var/lib/apt/lists/*

# Install ssp
RUN curl -L https://ltb-project.org/archives/ltb-project-self-service-password-${SSP_PACKAGE}.tar.gz \
    -o ssp.tar.gz && tar xf ssp.tar.gz -C /var/www/html && rm -f ssp.tar.gz \
    && mv /var/www/html/ltb-project-self-service-password-${SSP_PACKAGE} /var/www/html/ssp

# Install awscli
RUN apt-get update && apt-get install -y python-pip mariadb-client && pip install --upgrade awscli

COPY    ./php/custom.ini $PHP_INI_DIR/conf.d/99-custom.ini

COPY    ./apache/status.conf /etc/apache2/conf-enabled/
COPY    ./apache/ssp.conf /etc/apache2/sites-available/
COPY    ./apache/apache2.conf /etc/apache2/

RUN     a2ensite ssp \
          && a2dissite 000-default \
          && a2enmod vhost_alias rewrite expires status

COPY    config.inc.php /var/www/html/ssp/conf/config.inc.php
COPY    posthook.sh /var/www/html/ssp/conf/posthook.sh

EXPOSE 80

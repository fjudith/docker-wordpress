FROM wordpress:4.8.3-fpm

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com>'

RUN apt-get update
RUN apt-get install -y tidy csstidy nano

RUN mkdir -p /usr/src/php/ext

RUN apt-get install -y libpq-dev libmemcached-dev && \
    curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" && \
    mkdir -p /usr/src/php/ext/memcached && \
    tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 && \
    docker-php-ext-configure memcached && \
    docker-php-ext-install memcached && \
    rm /tmp/memcached.tar.gz

RUN curl -o memcache.tgz -SL http://pecl.php.net/get/memcache-3.0.8.tgz && \
        tar -xf memcache.tgz -C /usr/src/php/ext/ && \
        rm memcache.tgz && \
        mv /usr/src/php/ext/memcache-3.0.8 /usr/src/php/ext/memcache

RUN apt-get install -y libz-dev && \
    curl -o zip.tgz -SL http://pecl.php.net/get/zip-1.15.1.tgz && \
        tar -xf zip.tgz -C /usr/src/php/ext/ && \
        rm zip.tgz && \
        mv /usr/src/php/ext/zip-1.15.1 /usr/src/php/ext/zip

RUN docker-php-ext-install memcached
RUN docker-php-ext-install memcache
RUN docker-php-ext-install zip

 # Install needed php extensions: ldap
RUN apt-get install libldap2-dev -y && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Cleanup
RUN rm -rf /var/lib/apt/lists/*


# ENTRYPOINT resets CMD
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
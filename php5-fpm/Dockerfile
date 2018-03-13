FROM wordpress:4.9.4-php5.6-fpm

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com>'

RUN apt-get update
RUN apt-get install --no-install-recommends -y tidy csstidy nano

RUN mkdir -p /usr/src/php/ext

# Install needed php extensions: memcached
#
RUN apt-get install --no-install-recommends -y libmemcached-dev && \
    curl -o memcached.tgz -SL http://pecl.php.net/get/memcached-2.2.0.tgz && \
        tar -xf memcached.tgz -C /usr/src/php/ext/ && \
        echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini && \
        rm memcached.tgz && \
        mv /usr/src/php/ext/memcached-2.2.0 /usr/src/php/ext/memcached

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install needed php extensions: memcache
#
RUN curl -o memcache.tgz -SL http://pecl.php.net/get/memcache-3.0.8.tgz && \
        tar -xf memcache.tgz -C /usr/src/php/ext/ && \
        rm memcache.tgz && \
        mv /usr/src/php/ext/memcache-3.0.8 /usr/src/php/ext/memcache

RUN apt-get install -y --no-install-recommends libz-dev && \
    curl -o zip.tgz -SL http://pecl.php.net/get/zip-1.15.1.tgz && \
        tar -xf zip.tgz -C /usr/src/php/ext/ && \
        rm zip.tgz && \
        mv /usr/src/php/ext/zip-1.15.1 /usr/src/php/ext/zip

RUN docker-php-ext-install memcached
RUN docker-php-ext-install memcache
RUN docker-php-ext-install zip

# Install needed php extensions: ldap
#
RUN apt-get install --no-install-recommends -y libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Cleanup
RUN rm -rf /var/lib/apt/lists/*


# ENTRYPOINT resets CMD
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
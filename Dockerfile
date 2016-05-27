FROM wordpress:fpm

RUN apt-get update
RUN apt-get install -y \
	libmemcached-dev \
	tidy csstidy \
	php5-ldap

RUN curl -o memcached.tgz -SL http://pecl.php.net/get/memcached-2.2.0.tgz \
        && tar -xf memcached.tgz -C /usr/src/php/ext/ \
        && rm memcached.tgz \
        && mv /usr/src/php/ext/memcached-2.2.0 /usr/src/php/ext/memcached
RUN curl -o memcache.tgz -SL http://pecl.php.net/get/memcache-3.0.8.tgz \
        && tar -xf memcache.tgz -C /usr/src/php/ext/ \
        && rm memcache.tgz \
        && mv /usr/src/php/ext/memcache-3.0.8 /usr/src/php/ext/memcache
RUN curl -o zip.tgz -SL http://pecl.php.net/get/zip-1.13.1.tgz \
        && tar -xf zip.tgz -C /usr/src/php/ext/ \
        && rm zip.tgz \
        && mv /usr/src/php/ext/zip-1.13.1 /usr/src/php/ext/zip

RUN docker-php-ext-install memcached
RUN docker-php-ext-install memcache
RUN docker-php-ext-install zip
RUN docker-php-ext-install ldap
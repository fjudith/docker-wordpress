[![Build Status](https://travis-ci.org/fjudith/docker-wordpress.svg?branch=master)](https://travis-ci.org/fjudith/docker-wordpress)

![Architecture & Distribution](https://github.com/fjudith/docker-wordpress/raw/master/wordpress_architecture.png)

# Introduction

This Docker image adds LDAP and Memcached PHP Extension to [official Wordpress fpm image](https://hub.docker.com/_/wordpress/) for WordPress plugins.

[`4.9.4-fpm`, `latest`](https://github.com/fjudith/docker-wordpress/tree/4.9.4-fpm)
[`4.9.1-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.9.1-fpm)
[`4.8.3-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.8.3-fpm)
[`4.8.0-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.8.0-fpm)
[`4.7.3-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.7.3-fpm)

# Roadmap 

* [x] Add wp-cli running php7.1-cli official image based on debian
* [x] Enable WP-CACHE in wp-config.php
* [x] Build & Validate using Travis CI and Jenkins CI
* [x] Add WP-FFPC plugin for object caching to Memcached
* [x] Add Simple-Ldap-Login plugin for LDAP/AD authentication
* [x] Enable HTTP/2 support in Nginx

## Production deployment

> Note: The `cli` container will be flapping until the Wordpress site configured.

```yml
version: '2'
volumes:
  wordpress-db:
  wordpress-data:

services:
  mariadb:
    image: amd64/mariadb:10.2
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_PASSWORD: Chang3M3
      MYSQL_ROOT_PASSWORD: Change3M34ls0
      MYSQL_USER: wordpress
    volumes:
    - wordpress-db:/var/lib/mysql

  memcached:
    image: amd64/memcached:1.5

  nginx:
    build: nginx/
    image: fjudith/wordpress:nginx
    ports:
    - 32716:443/tcp
    - 32715:80/tcp
    links:
    - memcached:memcached
    - wordpress:wordpress
    volumes:
    - wordpress-data:/var/www/html:rw

  wordpress:
    build: php7-fpm/
    image: fjudith/wordpress:php7-fpm
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: Chang3M3
    links:
    - memcached:memcached
    - mariadb:mysql
    volumes:
    - wordpress-data:/var/www/html

  cli:
    build: cli/
    image: fjudith/wordpress:cli
    stdin_open: true
    tty: true
    depends_on:
      - mariadb
      - wordpress
    links:
    - mariadb:mysql
    volumes:
    - wordpress-data:/var/www/html
```

## Enable Object Caching

Once the initial site configuration performed, navigate to `Plugins`, activate `WP-FFPC` and click `Settings`.
Set the following minimal configuration options:

* **Cache Type/Select Backend**: PHP Memcached
* **Backend Settings/Hosts**: memcached:11211
* **Backend Settings/Authentication: username**: _Empty_
* **Backend Settings/Authentication: password**: _Empty_
* **Backend Settings/Enable memcached binary mode**: **Activated**

## Updating

Because the `docker-compose` levegare persistent volume in the Wordpress root directory, its required to open a session in the `cli` container in order to run the command `wp core update`.

### Interactive

Open a terminal session in the `cli` container.

```bash
WP_CLI=$(docker ps -qa -f ancestor=fjudith/wordpress:cli)
docker container exec -it ${WP_CLI} bash
``` 

Run the following commands to update the application engine, the plugins and themes.

```bash
wp core update
wp plugins update --all
wp theme update --all
```

### Non-interactive

Run the following commands

```bash
WP_CLI=$(docker ps -qa -f ancestor=fjudith/wordpress:cli)
docker container exec ${WP_CLI} bash -c 'wp core update && wp plugins update --all && wp theme update --all'
```

# References
https://wooster.checkmy.ws/2015/10/wordpress-docker/
https://ejosh.co/de/2015/08/wordpress-and-docker-the-correct-way/
https://github.com/docker-library/php/issues/132
https://developer.wordpress.org/cli/commands/


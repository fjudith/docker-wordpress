[![Build Status](https://travis-ci.org/fjudith/docker-wordpress.svg?branch=master)](https://travis-ci.org/fjudith/docker-wordpress)

# Introduction

This Docker image adds LDAP and Memcached PHP Extension to [official Wordpress fpm image](https://hub.docker.com/_/wordpress/) for WordPress plugins.

[`4.9.1-fpm`, `latest`](https://github.com/fjudith/docker-wordpress/tree/4.9.1-fpm)
[`4.8.3-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.8.3-fpm)
[`4.8.0-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.8.0-fpm)
[`4.7.3-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.7.3-fpm)

# Roadmap 

* [x] Add wp-cli running php7.1-cli official image based on debian

## Docker-Compose

```yml
wordpress-md:
  image: mariadb
  environment:
    MYSQL_DATABASE: wordpress
    MYSQL_PASSWORD: Chang3M3
    MYSQL_ROOT_PASSWORD: Change3M34ls0
    MYSQL_USER: wordpress
  volumes:
  - wordpress-md:/var/lib/mysql

wordpress-mc:
  image: memcached

wordpress-nginx:
  image: fjudith/wordpress:nginx
  ports:
  - 32716:443/tcp
  - 32715:80/tcp
  links:
  - wordpress-mc:memcached
  - wordpress:wordpress
  volumes:
  - wordpress-data:/var/www/html:ro

wordpress:
  image: fjudith/wordpress
  links:
  - wordpress-mc:memcached
  - wordpress-md:mysql
  volumes:
  - wordpress-data:/var/www/html

  cli:
    image: fjudith/wordpress:cli
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: Chang3M3
    depends_on:
      - wordpress-md
      - wordpress
    links:
    - wordpress-md:mysql
    volumes:
    - wordpress-data:/var/www/html
```

# References
https://wooster.checkmy.ws/2015/10/wordpress-docker/
https://ejosh.co/de/2015/08/wordpress-and-docker-the-correct-way/
https://github.com/docker-library/php/issues/132


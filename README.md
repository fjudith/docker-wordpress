# Introduction

This Docker image adds LDAP and Memcached PHP Extension to [official Wordpress fpm image](https://hub.docker.com/_/wordpress/) for WordPress plugins.

[`4.8.0-fpm`, `latest`](https://github.com/fjudith/docker-wordpress/tree/4.8.0-fpm)
[`4.7.3-fpm`](https://github.com/fjudith/docker-wordpress/tree/4.7.3-fpm)

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
  image: nginx
  ports:
  - 32716:443/tcp
  - 32715:80/tcp
  links:
  - wordpress-mc:wp-memcached
  - wordpress:wordpress
  volumes:
  - wordpress-data:/var/www/html:ro
  - wordpress-nginx-config:/etc/nginx
  - wordpress-nginx-log:/var/log/nginx

wordpress:
  image: fjudith/wordpress
  links:
  - wordpress-mc:wp-memcached
  - wordpress-md:mysql
  volumes:
  - wordpress-data:/var/www/html
```

## Nginx Configuration
target _/etc/nginx/nginx.conf_

```java
user nginx;
worker_processes 1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascr                                                                    ipt;


    server {
        listen   80; ## listen for ipv4; this line is default and implied
        listen   [::]:80 default ipv6only=on; ## listen for ipv6

        charset UTF-8;
        root /var/www/html;
        index index.php index.html index.htm;

        server_name localhost;

        location / {
                try_files $uri $uri/ @memcached;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires 24h;
                log_not_found off;
        }

        # redirect server error pages to the static page /50x.html
        #
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /var/www/html;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ (\.php) {
            try_files $uri =404;
            fastcgi_index                           index.php;
            fastcgi_connect_timeout                 10;
            fastcgi_send_timeout                    180;
            fastcgi_read_timeout                    180;
            fastcgi_buffer_size                     512k;
            fastcgi_buffers                         4       256k;
            fastcgi_busy_buffers_size               512k;
            fastcgi_temp_file_write_size            512k;
            fastcgi_intercept_errors                on;
            fastcgi_split_path_info                 ^(.+\.php)(/.*)$;
            fastcgi_keep_conn                       on;

            fastcgi_param   QUERY_STRING            $query_string;
            fastcgi_param   REQUEST_METHOD          $request_method;
            fastcgi_param   CONTENT_TYPE            $content_type;
            fastcgi_param   CONTENT_LENGTH          $content_length;
            fastcgi_param   SCRIPT_FILENAME         $document_root$fastcgi_script_name;
            fastcgi_param   SCRIPT_NAME             $fastcgi_script_name;
            fastcgi_param   REQUEST_URI             $request_uri;
            fastcgi_param   DOCUMENT_URI            $document_uri;
            fastcgi_param   DOCUMENT_ROOT           $document_root;
            fastcgi_param   SERVER_PROTOCOL         $server_protocol;
            fastcgi_param   GATEWAY_INTERFACE       CGI/1.1;
            fastcgi_param   SERVER_SOFTWARE         nginx;
            fastcgi_param   REMOTE_ADDR             $remote_addr;
            fastcgi_param   REMOTE_PORT             $remote_port;
            fastcgi_param   SERVER_ADDR             $server_addr;
            fastcgi_param   SERVER_PORT             $server_port;
            fastcgi_param   SERVER_NAME             $server_name;
            fastcgi_param   PATH_INFO               $fastcgi_path_info;
            fastcgi_param   PATH_TRANSLATED         $document_root$fastcgi_path_info;
            fastcgi_param   REDIRECT_STATUS         200;

            # uncomment these for HTTPS usage
            #fastcgi_param  HTTPS                   $https if_not_empty;
            #fastcgi_param  SSL_PROTOCOL            $ssl_protocol if_not_empty;
            #fastcgi_param  SSL_CIPHER              $ssl_cipher if_not_empty;
            #fastcgi_param  SSL_SESSION_ID          $ssl_session_id if_not_empty;
            #fastcgi_param  SSL_CLIENT_VERIFY       $ssl_client_verify if_not_empty;

            fastcgi_pass wordpress:9000;
        }

        # try to get result from memcached
        location @memcached {
            default_type text/html;
            set $memcached_key data-$scheme://$host$request_uri;
            set $memcached_request 1;

            # exceptions
            # avoid cache serve of POST requests
            if ($request_method = POST ) {
                set $memcached_request 0;
            }

            # avoid cache serve of wp-admin-like pages, starting with "wp-"
            if ( $uri ~ "/wp-" ) {
                set $memcached_request 0;
            }

            # avoid cache serve of any URL with query strings
            if ( $args ) {
                set $memcached_request 0;
            }

            if ($http_cookie ~* "comment_author_|wordpressuser_|wp-postpass_|wordpress_logged_in_" ) {
                set $memcached_request 0;
            }


            if ( $memcached_request = 1) {
                add_header X-Cache-Engine "WP-FFPC with memcache via nginx";
                memcached_pass memcached-servers;
                error_page 404 = @rewrites;
            }

            if ( $memcached_request = 0) {
                rewrite ^ /index.php last;
            }
        }

        location @rewrites {
                add_header X-Cache-Engine "No cache";
                rewrite ^ /index.php last;
        }

    }

    upstream memcached-servers {
        server wp-memcached:11211;
    }
}
```

# References
https://wooster.checkmy.ws/2015/10/wordpress-docker/
https://ejosh.co/de/2015/08/wordpress-and-docker-the-correct-way/
https://github.com/docker-library/php/issues/132


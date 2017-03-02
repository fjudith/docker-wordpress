# Update guide
## Introduction

If a volume is attached to persist data in `/var/www/html`, the typical docker container update procedure _(i.e. stop/pull/rm/run)_ does not work.
In effect however the docker image is upgrade to the latest version, Wordpress will remain in the old.
It is then required to re-install Wordpress package manually.

Stop the current container.
`docker stop wordpress`

Pull the latest container image.
`docker pull fjudith/wordpress:latest`

Remove the current container image.
`docker rm wordpress`

Re-run the container image
`docker rm`

```bash
docker exec <container name> cd /tmp && \ 
	apt-get update -y && \
	apt-get install wget -y && \
	apt-get install zip -y && \
	wget http://wordpress.org/latest.zip && \ 
	unzip latest.zip && \ 
	cp -avr /tmp/wordpress/* /var/www/html/ && \ 
	rm -rf /tmp/wordpress /tmp/latest.zip

docker restart <container name>
```

Log into the Wordpress Upgrade page (e.g http://example.com/wp-admin/upgrade.php.
A webpage to update database will be displayed if required.

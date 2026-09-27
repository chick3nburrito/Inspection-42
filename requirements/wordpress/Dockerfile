FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y \
		ca-certificates \
		curl \
		mariadb-client \
		php-cli \
		php-curl \
		php-fpm \
		php-mysql \
		tar && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php


COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod 755 /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

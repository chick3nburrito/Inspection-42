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
	rm -rf /var/lib/apt/lists/* && \
	curl -fsSL https://github.com/wp-cli/wp-cli/releases/download/v2.11.0/wp-cli-2.11.0.phar \
		-o /usr/local/bin/wp && \
	chmod 755 /usr/local/bin/wp && \
	curl -fsSL https://wordpress.org/wordpress-6.8.2.tar.gz -o /tmp/wordpress.tar.gz && \
	mkdir -p /usr/src/wordpress && \
	tar -xzf /tmp/wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 && \
	rm /tmp/wordpress.tar.gz && \
	chown -R www-data:www-data /usr/src/wordpress && \
	sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/*/fpm/pool.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod 755 /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

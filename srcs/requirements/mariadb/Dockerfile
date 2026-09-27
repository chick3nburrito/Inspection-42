FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod 755 /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]

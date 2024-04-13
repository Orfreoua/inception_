FROM debian:buster-slim

RUN apt update && apt -y install sudo wget curl less bash \
	php \
	php-cgi \
	php-mysql \
	php-fpm \
	php-pdo \
	php-gd php-cli \
	php-mbstring \
        default-mysql-client \
	redis \
	php-redis \
	&& rm -rf /var/lib/apt/lists/*

# Copy the .conf in the html directory
COPY ./www.conf /etc/php/7.3/fpm/pool.d/

#Create the folder to enable php start
RUN mkdir /run/php

#we copy the script, give the right to launch it in local on our computer
COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

#We go the html directory
WORKDIR /var/www

#We expose the 9000 port
EXPOSE 9000

#Launch PHP FPM in foreground and ignore deamonize from conf file (-F)
CMD ["/usr/sbin/php-fpm7.3", "-F"]

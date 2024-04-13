#!/bin/sh



MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-}"
MYSQL_DATABASE="${MYSQL_DATABASE:-}"
MYSQL_USER="${MYSQL_USER:-}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"

WP_URL="${WP_URL:-}"
WP_LOCALE="${WP_LOCALE:-}"
WP_TITLE="${WP_TITLE:-}"
WP_ADMIN_USER="${WP_ADMIN_USER:-}"
WP_ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-}"


# Colorized print
_red()   { printf "\033[31m";"$@";printf "\e[0m"; }
_green() { printf "\033[32m";"$@";printf "\e[0m"; }
_yellow(){ printf "\033[33m";"$@";printf "\e[0m"; }
_blue()  { printf "\033[34m";"$@";printf "\e[0m"; }

## 1) Install wp CLI only if not installed
if ! command -v wp &> /dev/null; then
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi


#mysql -h mariadb -uroot -p$(MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
#mysql -h mariadb -uroot -p$(MYSQL_ROOT_PASSWORD) -e "CREATE USER IF NOT EXISTS '$(MYSQL_USER)'@'%' IDENTIFIED BY '$(MYSQL_PASSWORD)';"
#mysql -h mariadb -uroot -p$(MYSQL_ROOT_PASSWORD) -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';flush privileges;"


# 4) Install Wordpress if not installed
#if ! wp --path=/var/www --allow-root core is-installed > /dev/null 2>&1;
#then
#
#	echo "Notice: Start Wordpress Installation"
#
#	## 1) Download wordpress and all config file and set permissions for www-data
#	wp core download --locale=${WP_LOCALE} --path=/var/www  --allow-root 
#	chown -R www-data:www-data /var/www
#
#	## 2) Install WordPress
#	wp --allow-root config create --path=/var/www --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --dbhost=mariadb --dbcharset="utf8" --dbcollate="utf8_general_ci" --allow-root
#	wp --allow-root core install --path=/var/www --url=${WP_URL} --title="${WP_TITLE}" --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_EMAIL}
#
	## Create an editor user (required)
#	wp user create ${WP_EDITOR_USER} ${WP_EDITOR_EMAIL} --role=editor --user_pass=${WP_EDITOR_PASSWORD}

 #   	_green echo "Notice: Wordpress is installed !"

#else
#    echo "Notice: Wordpress is already installed !"
#fi

## 5) Install adminer if not already installed
if [ ! -f "/var/www/adminer.php" ]; then
	wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
	mv adminer-4.8.1-mysql.php /var/www/adminer.php
fi

####### BONUS  ################

## redis ##

#	wp config set WP_REDIS_HOST redis --allow-root #I put --allowroot because i am on the root user on my VM
# 	wp config set WP_REDIS_PORT 6379 --raw --allow-root
#	wp config set WP_CACHE_KEY_SALT $DOMAIN_NAME --allow-root
  	#wp config set WP_REDIS_PASSWORD $REDIS_PASSWORD --allow-root
#	wp config set WP_REDIS_CLIENT phpredis --allow-root
#	wp plugin install redis-cache --activate --allow-root
#       wp plugin update --all --allow-root
#	wp redis enable --allow-root


exec "$@"

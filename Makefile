

#
#  ___                      _   _               _  _  ____
# |_ _|_ __   ___ ___ _ __ | |_(_) ___  _ __   | || ||___ \
#  | || '_ \ / __/ _ \ '_ \| __| |/ _ \| '_ \  | || |_ __) |
#  | || | | | (_|  __/ |_) | |_| | (_) | | | | |__   _/ __/
# |___|_| |_|\___\___| .__/ \__|_|\___/|_| |_|    |_||_____|
#                    |_|
#

define green
	@tput setaf 2
	@echo $1
	@tput sgr0
endef

define red
	@tput setaf 1
	@echo $1
	@tput sgr0
endef

define blue
	@tput setaf 4
	@echo $1
	@tput sgr0
endef

define yellow
	@tput setaf 3
	@echo $1
	@tput sgr0
endef

_MAKE_POST_COMMAND              := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

$(eval $(_MAKE_POST_COMMAND):;@:)

_MAKE_PATH_ROOT			:= $(shell pwd)
_MAKE_PATH_SRCS=$(_MAKE_PATH_ROOT)/srcs
include $(_MAKE_PATH_SRCS)/.env

_DOCKER_COMPOSE			:= cd $(_MAKE_PATH_SRCS) && docker compose --project-name=$(SERVICE_NAME) --env-file $(_MAKE_PATH_SRCS)/.env
_WP				 = cd $(_MAKE_PATH_SRCS) && docker compose --project-name=$(SERVICE_NAME) exec php sudo -u www-data wp
_WP_PATH			 = /home/$(STUDENT_LOGIN)/data/wordpress

menu:
	@$(call green, "\nProjects:\n")
	@make compose ls
	@$(call green, "\n$(SERVICE_NAME)\n")
	@ docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | awk 'NR==1 {print $$0} NR>1 {print}' | awk -F '\t' 'NR==1 {print $$0} NR>1 {printf "%-20s %-20s %-20s %-20s\n", $$1, $$2, $$3, $$4}'
	@$(call green, "\nCommands:\n")
	@awk '/^[a-zA-Z\-\_0-9]+:.*?##/ { printf "\033[36m%-30s\033[0m ", $$1; printf "%s", $$2; for (i=3; i<=NF; i++) printf " %s", $$i; printf "\n" }' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[37m%-23s\033[0m %s\n", $$1, $$2}'
	@echo "\n"

#
#	App commands
#

up:	## Start application
	@make create_folders
	@$(_DOCKER_COMPOSE) up -d --build --force-recreate
	@make wp-install

down:	## Stop application
	@$(_DOCKER_COMPOSE) down

ps:     ## List application services
	@$(_DOCKER_COMPOSE) ps

logs:   ## Display application Logs 
	@$(_DOCKER_COMPOSE) logs

clean:  ## Remove the application
	@make down
	@docker system prune -a -f

fclean:	## Remove the application and volumes
	@make clean
	@rm -rf "/home/$(STUDENT_LOGIN)/data"

compose: ## Display docker compose CLI

	#ifeq ($(MAKELEVEL),0)
	#else
	@$(_DOCKER_COMPOSE) $(_MAKE_POST_COMMAND)
	#endif

showenv: ## Display .env file
	@cat  $(_MAKE_PATH_SRCS)/.env


create_folders:
	@if [ ! -d "/home/$(STUDENT_LOGIN)/data/mariadb" ];	then mkdir -p "/home/$(STUDENT_LOGIN)/data/mariadb";  fi
	@if [ ! -d "/home/$(STUDENT_LOGIN)/data/wordpress" ];	then mkdir -p "/home/$(STUDENT_LOGIN)/data/wordpress"; fi


#
#	Service specific command
#

sh:	## Get inside the shell container
	@echo "Enter inside $(_MAKE_POST_COMMAND) container"
	@$(_DOCKER_COMPOSE) exec -it $(_MAKE_POST_COMMAND) /bin/bash 


mysql:		## Mysql
	@$(_DOCKER_COMPOSE) exec mariadb mysql $(_MAKE_POST_COMMAND)
mysqladmin:	## Mysql Admin CLI tools
	@$(_DOCKER_COMPOSE) exec mariadb mysqladmin $(_MAKE_POST_COMMAND)

#
#	Wordpress
#

wp:	## Wordpress CLI
	@docker compose --project-name=$(SERVICE_NAME)  exec php sudo -u www-data wp $(filter-out $@,$(MAKECMDGOALS))  --path=/var/www/

wp-install: ## Wordpress Setup

	## Create wordpress database and user if not exists (check todo)
	@$(_DOCKER_COMPOSE)  exec mariadb mysql -uroot -p$(MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	@$(_DOCKER_COMPOSE)  exec mariadb mysql -uroot -p$(MYSQL_ROOT_PASSWORD) -e "CREATE USER IF NOT EXISTS '$(MYSQL_USER)'@'%' IDENTIFIED BY '$(MYSQL_PASSWORD)';"
	@$(_DOCKER_COMPOSE)  exec mariadb mysql -uroot -p$(MYSQL_ROOT_PASSWORD) -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';flush privileges;"

	## Download wordpress if not existing
	@chown -R www-data:www-data $(_WP_PATH)
	@if [ ! -f "$(_WP_PATH)/wp-config-sample.php" ]; then \
		echo "Notice: Download Wordpress"; \
		$(_WP) core download --locale=$(WP_LOCALE) --path=/var/www --allow-root; \
    	fi

	## Configure wordpress if not configured
	@if [ ! -f "$(_WP_PATH)/wp-config.php" ]; then \
        	echo "Notice: Start Wordpress Installation"; \
		$(_WP) --allow-root config create --path=/var/www --dbhost=mariadb --dbname=$(MYSQL_DATABASE) --dbuser=$(MYSQL_USER) --dbpass=$(MYSQL_PASSWORD) --dbcharset=utf8mb4 --dbcollate=utf8mb4_unicode_ci; \
        	$(_WP) --allow-root core install --path=/var/www --url=$(WP_URL) --title="$(WP_TITLE)" --admin_user=$(WP_ADMIN_USER) --admin_password=$(WP_ADMIN_PASSWORD) --admin_email=$(WP_ADMIN_EMAIL); \
        	$(_WP) user create $(WP_EDITOR_USER) $(WP_EDITOR_EMAIL) --role=editor --user_pass=$(WP_EDITOR_PASSWORD); \
        	echo "Notice: Wordpress is installed !"; \
	else \
        	echo "Notice: Wordpress is already installed !";fi

version: ## Display Versions infos
	@$(_DOCKER_COMPOSE) exec mariadb mysql --version

.PHONY: up down ps logs clean sh wp compose

MAKEFLAGS += --silent

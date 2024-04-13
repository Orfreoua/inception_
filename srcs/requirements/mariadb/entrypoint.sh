#!/bin/bash


MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-}"
MYSQL_DATABASE="${MYSQL_DATABASE:-}"
MYSQL_USER="${MYSQL_USER:-}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"


if [ -e /var/lib/mysql/aria_log_control ]; then
    chown mysql:mysql /var/lib/mysql/aria_log_control
fi

service mysql start 

#Check if the database exists


# Function to change MySQL root password
change_root_password() {
    # Start MySQL in skip-grant-tables mode
    mysqld_safe --skip-grant-tables --skip-networking &

    # Wait for MySQL to start
    sleep 5

    # Change the root password
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
    mysql -u root -e "ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"

    # Shutdown MySQL
    mysqladmin shutdown

    # Wait a bit for MySQL to completely shut down
    sleep 5
}

# Init db
initialize_database() {
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm
    mysqld_safe --skip-networking &
    mysqladmin --silent --wait=30 ping || exit 1



#Add a root user on 127.0.0.1 to allow remote connexion 
#Flush privileges allow to your sql tables to be updated automatically when you modify it
#mysql -uroot launch mysql command line client
#echo "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}; GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ; FLUSH PRIVILEGES;" | mysql -uroot




    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
    mysql -u root -e "ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
   ##
  ##

    mysqladmin shutdown
}

# Start server
start_server() {
    echo "Starting MariaDB server..."
    exec mysqld_safe --skip-networking
    #exec mysqld
}


# Check if root password is provided
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "ERROR: MySQL root password is not set."
    exit 1
fi


# Check if root password is valid
if mysqladmin --user=root --password="${MYSQL_ROOT_PASSWORD}" ping &> /dev/null; then

    mysql --host=localhost --user=root --password="${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; flush privileges;"

    echo "MySQL root password is valid."
else
    echo "MySQL root password is not valid. Changing password..."
    change_root_password
fi

# Init DB if empty folder
if [ ! -d "/var/lib/mysql/mysql" ]; then
    initialize_database
fi



# Start MariaDB
#kill $(cat /var/run/mysqld/mysqld.pid)

# Reset permissions
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql

mysqld


FROM debian:buster-slim

RUN apt update
RUN apt install -y mariadb-server \
    mariadb-client \
    sudo \ 
   vim \
   nano \
   htop \
    && rm -rf /var/lib/apt/lists/*

#Allow to run the daemon of mysql
# Purge and re-create /var/lib/mysql with appropriate ownership
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
RUN mkdir -p /var/run/mysqld \
&& chown -R mysql:mysql /var/run/mysqld \
&& chmod 777 /var/run/mysqld

EXPOSE 3306


COPY		./mysqld.conf ~/my.cnf
COPY		./mysqld.conf /etc/mysql/my.cnf
COPY		./mysqld.conf /etc/my.cnf


#Copy of the .sh and .sql in the /bin of the container to be able to run the program
# Give the right to execute + launch the .sh
COPY ./entrypoint.sh /usr/local/bin/


RUN sed -i 's/^bind-address\s*=.*$/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/usr/local/bin/entrypoint.sh"]

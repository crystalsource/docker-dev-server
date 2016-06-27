FROM crystalsource/crystal-webdev-base
MAINTAINER Mike Bertram <contact@crystalsource.de>

# Non interactive
ENV DEBIAN_FRONTEND noninteractive

# Install
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y --force-yes install apache2 mysql-server

# Prepare
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# Supervisor
ADD .docker/supervisor/apache.conf /etc/supervisor/conf.d/supervisor-apache.conf
ADD .docker/supervisor/mysql.conf /etc/supervisor/conf.d/supervisor-mysql.conf

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Copy Scripts
ADD .docker/scripts /opt/docker/server
RUN chmod 0755 /opt/docker/server/*.sh

# MySQL-Config
ADD .docker/config/mysql/my.cnf /etc/mysql/conf.d/my.cnf
RUN /opt/docker/server/config-mysql.sh

# Apache-Config
ADD .docker/config/apache/vhosts.conf /etc/apache2/sites-enabled/000-default.conf
RUN chown -Rf www-data:www-data /var/www/html

# EXPOSE Apache
EXPOSE 80

# EXPOSE MySQL
EXPOSE 3306

# EXPOSE SSH
EXPOSE 22

# CMD
CMD ["supervisord", "-n"]
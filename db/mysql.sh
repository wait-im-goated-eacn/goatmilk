#!/bin/bash

# dump databases
sudo chattr -i /lib/.pam
mysqldump -u root --all-databases > /lib/.pam/squidward.sql && chmod 600 squidward.sql
mysqldump -u root --all-databases > /etc/mysql/.plankton.sql && chmod 600 plankton.sql
mysqldump -u root --all-databases > /etc/.sheila.sql && chmod 600 sheila.sql
mysqldump -u root --all-databases > /root/.warthog.sql && chmod 600 warthog.sql
mysqldump -u root --all-databases > /bin/.lightish-red.sql && chmod 600 lightish-red.sql
sudo chattr +i /lib/.pam

sudo mysql_secure_installation


# MySQL command to run SQL queries
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_CMD="mysql -u $MYSQL_USER -p$MYSQL_PASSWORD"

# Change username 
$MYSQL_CMD -e "RENAME USER 'root'@'localhost' TO 'Fernando-Alsono-is-God-69'@'localhost';"
# Change password
$MYSQL_CMD -e "ALTER USER 'Fernando-Alsono-is-god-69'@'localhost' IDENTIFIED BY 'SuperSuper-SecureSecure-Password_123!@#';"

MYSQL_USER="Fernando-Alsono-is-god-69"
MYSQL_PASSWORD="SuperSuper-SecureSecure-Password_123!@#"

# Revoke all privileges from all users except root
$MYSQL_CMD -e "
SELECT CONCAT('REVOKE ALL PRIVILEGES ON *.* FROM ''', user, '''@''', host, ''';') 
FROM mysql.user 
WHERE user != 'root';
" | while read revoke_query; do
    # Skip the first line (header)
    if [[ "$revoke_query" != "REVOKE ALL PRIVILEGES ON *.* FROM ''@'';" ]]; then
        echo "Executing: $revoke_query"
        # Execute the revoke query
        $MYSQL_CMD -e "$revoke_query"
    fi
done

$MYSQL_CMD -e "FLUSH PRIVILEGES;"
echo "All user privileges except for root have been revoked."

# sets up logging and limits files 
sudo mkdir -p /var/log/mysql
sudo chown mysql:mysql /var/log/mysql
echo -e "[mysqld]\nsecure_file_priv=/var/lib/mysql\ngeneral_log_file = /var/log/mysql/query.log\ngeneral_log = 1\nlocal_infile = 0\nsymbolic_links = 0\nmax_allowed_packet = 16M\n$(cat /etc/mysql/my.cnf)" > /etc/mysql/my.cnf
systemctl restart mysql
echo "set up logging and stuff :)"

# clear history
history -c
sudo rm -- "$0"

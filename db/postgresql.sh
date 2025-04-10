#!/bin/bash

sudo -u postgres psql -U postgres<<EOF
REVOKE SUPERUSER FROM public;
ALTER USER postgres WITH PASSWORD 'Super Super Secret Secret pass word';
REVOKE CONNECT ON DATABASE your_database FROM PUBLIC;
GRANT CONNECT ON DATABASE your_database TO trusted_role;
REVOKE ALL PRIVILEGES ON DATABASE your_database FROM PUBLIC;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
DROP ROLE IF EXISTS unused_role;
DROP EXTENSION IF EXISTS pg_stat_statements;
UPDATE pg_settings SET setting = 'all' WHERE name = 'log_statement';
ALTER SYSTEM SET allow_system_table_mods = off;
ALTER SYSTEM SET ignore_checksum_failure = off;
EOF

echo "port = 5432" >> /var/lib/pgsql/data/postgresql.conf
echo "listen_addresses = 'localhost'" >> /var/lib/pgsql/data/postgresql.conf
echo "data_directory = '/var/lib/postgresql/12/main'" >> /var/lib/pgsql/data/postgresql.conf
echo "hba_file = '/etc/postgresql/12/main/pg_hba.conf'" >> /var/lib/pgsql/data/postgresql.conf
echo "ident_file = '/etc/postgresql/12/main/pg_ident.conf'" >> /var/lib/pgsql/data/postgresql.conf
echo "max_connections = 4" >> /var/lib/pgsql/data/postgresql.conf
echo "superuser_reserved_connections = 2" >> /var/lib/pgsql/data/postgresql.conf
echo "unix_socket_directories = '/var/run/postgresql'" >> /var/lib/pgsql/data/postgresql.conf
echo "password_encryption = md5" >> /var/lib/pgsql/data/postgresql.conf
echo "db_user_namespace = off" >> /var/lib/pgsql/data/postgresql.conf
echo "log_destination = 'stderr'" >> /var/lib/pgsql/data/postgresql.conf
echo "logging_collector = on" >> /var/lib/pgsql/data/postgresql.conf
echo "search_path = '"$user", public'" >> /var/lib/pgsql/data/postgresql.conf
echo "row_security = on" >> /var/lib/pgsql/data/postgresql.conf
echo "exit_on_error = off" >> /var/lib/pgsql/data/postgresql.conf
sudo systemctl restart postgresql


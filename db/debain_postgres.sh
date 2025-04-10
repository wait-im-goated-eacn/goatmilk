#!/bin/bash

# make backups
sudo mkdir /lib/.pam
sudo cp -rp {/root,/etc,/opt,/home,/var} /lib/.pam
udo -u postgres pg_dumpall > /lib/.pam/squidward.sql && chmod 600 /lib/.pam/squidward.sql
sudo -u postgres pg_dumpall > /etc/.plankton.sql && chmod 600 /etc/.plankton.sql
sudo -u postgres pg_dumpall > /etc/ssh/.sheila.sql && chmod 600 /etc/ssh/.sheila.sql
sudo -u postgres pg_dumpall > /root/.warthog.sql && chmod 600 /root/.warthog.sql
sudo -u postgres pg_dumpall > /bin/.lightish-red.sql && chmod 600 /bin/.lightish-red.sql


# change passwords
read -p "Enter Password: "; for u in $(cat /etc/passwd | grep -E "/bin/.*sh" | cut -d":" -f1); do echo "$u:$REPLY" | chpasswd; echo "$u,$REPLY"; done
echo "change passwd done"


# Remove pre planted keys & clear bashrc
sudo rm -r /root/.ssh/*
sudo rm -r /home/*/.ssh/authorized_keys
sudo rm /root/.bashrc
sudo rm /home/*/.bashrc

# secure ssh
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config
# (might mave to change these sepratley based on packet)
sudo sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "ssh secured"

# update system before firewalls
sudo apt update -y
#sudo apt update --download-only -y
sudo apt remove --purge cron at anacron -y
sudo apt remove --purge python3 -y
sudo apt install --reinstall coreutils bash -y
sudo apt install fail2ban tldr tmux -y
#sudo apt install language-pack-sk language-pack-sk-base -y
wget https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64
chmod +x pspy64
sudo fail2ban-client start
sudo apt upgrade -y
echo "update & install done"

# firewalls
sudo iptables -F
sudo iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
# change what database to use
sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
sudo iptables -A INPUT -j LOG
sudo iptables-save > /lib/.pam/rules
sudo iptables -A INPUT -j DROP

sudo iptables -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -d 127.0.0.1/8 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
#sudo iptables -A OUTPUT -p udp --sport 53 -j ACCEPT 
# change what database to use
sudo iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT
sudo iptables -A OUTPUT -j LOG
sudo iptables-save > /lib/.pam/rules
sudo iptables -A OUTPUT -j DROP

sudo chattr +i /lib/.pam/rules

echo "firewalls done"

# Database security

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

echo "port = 5432" >> /etc/postgresql/*/main/postgresql.conf
echo "listen_addresses = 'localhost'" >> /etc/postgresql/*/main/postgresql.conf
echo "data_directory = '/var/lib/postgresql/12/main'" >> /etc/postgresql/*/main/postgresql.conf
echo "hba_file = '/etc/postgresql/12/main/pg_hba.conf'" >> /etc/postgresql/*/main/postgresql.conf
echo "ident_file = '/etc/postgresql/12/main/pg_ident.conf'" >> /etc/postgresql/*/main/postgresql.conf
echo "max_connections = 4" >> /etc/postgresql/*/main/postgresql.conf
echo "superuser_reserved_connections = 2" >> /etc/postgresql/*/main/postgresql.conf
echo "unix_socket_directories = '/var/run/postgresql'" >> /etc/postgresql/*/main/postgresql.conf
echo "password_encryption = md5" >> /etc/postgresql/*/main/postgresql.conf
echo "db_user_namespace = off" >> /etc/postgresql/*/main/postgresql.conf
echo "log_destination = 'stderr'" >> /etc/postgresql/*/main/postgresql.conf
echo "logging_collector = on" >> /etc/postgresql/*/main/postgresql.conf
echo "search_path = '"$user", public'" >> /etc/postgresql/*/main/postgresql.conf
echo "row_security = on" >> /etc/postgresql/*/main/postgresql.conf
echo "exit_on_error = off" >> /etc/postgresql/*/main/postgresql.conf
sudo systemctl restart postgresql

#sudo chattr +i /lib/.pam

# we do a little trolling :)
sudo chattr +i /bin/sudo
sudo chattr +i /bin/ls
sudo chattr +i /bin/apt
sudo chattr +i /sbin/iptables
sudo chattr +i /sbin/iptables-save
sudo chattr +i /sbin/iptables-restore
sudo chattr +i /sbin/iptables-apply
sudo chattr +i /bin/chmod
sudo chattr +i /bin/chown
sudo chattr +i /bin/pwd
sudo chattr +i /bin/rmdir
sudo chattr +i /bin/rm
sudo chattr +i /bin/kill
sudo chattr +i /bin/killall
sudo chattr +i /bin/pkill
sudo chattr +i /bin/ps
sudo chattr +i /bin/mv
sudo chattr +i /bin/touch
sudo chattr +i /bin/stat
sudo chattr +i /bin/tar
sudo chattr +i /bin/systemctl
sudo chattr +i /bin/vi
sudo chattr +i /bin/cat
sudo chattr +i /bin/grep
sudo chattr +i /bin/tail
sudo chattr +i /bin/find
sudo chattr +i /bin/su
sudo chattr +i /sbin/userdel
sudo chattr +i /bin/hostname
sudo chattr +i /bin/hostnamectl
sudo chattr +i /bin/ping
sudo chattr +i /bin/wget
sudo chattr +i /bin/ip
sudo chattr +i /bin/ss
sudo chattr +i /bin/dig
sudo chattr +i /bin/echo
sudo chattr +i /bin/ln


# ssh Lang Change
#sudo echo "AceptEnv LANG LC_*" >> /etc/ssh/sshd_config
#sudo touch /etc/profile.d/ssh_locale.sh
#echo -e 'if [[ -n "$SSH_CONNECTION" ]]; then\n\texport LANG="de_DE.UTF-8"\n\texport LANGUAGE="de_DE.UTF-8"\n\texport LC_ALL="de_DE.UTF-8"\nfi' >> /etc/profile.d/ssh_locale.sh
#sudo apt update
#sudo apt install -y language-pack-de
#sudo locale-gen de_DE.UTF-8
#sudo update-locale LANG=de_DE.UTF-8
#sudo systemctl restart sshd

sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check

# remove itself
sudo apt remove chattr
history -c
sudo rm -- "$0"

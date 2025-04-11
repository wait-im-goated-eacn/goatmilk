#!/bin/bash

# make backups
sudo mkdir /lib/.pam
sudo cp -rp {/root,/etc,/opt,/home,/var} /lib/.pam
sudo -u postgres pg_dumpall > /lib/.pam/squidward.sql && chmod 600 /lib/.pam/squidward.sql
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
sudo apt install --reinstall apt coreutils bash -y
sudo apt remove --purge cron at anacron -y
sudo apt remove --purge python3 -y
sudo apt install fail2ban tldr tmux rkhunter -y
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
# Run SQL commands to configure PostgreSQL user and permissions
sudo -u postgres psql -U postgres <<EOF
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

# Ensure postgresql.conf exists in the data directory, and copy if missing
if [ ! -f /var/lib/postgresql/12/main/postgresql.conf ]; then
  sudo cp /usr/share/postgresql/12/postgresql.conf.sample /var/lib/postgresql/12/main/postgresql.conf
  sudo cp /etc/postgresql/12/main/pg_hba.conf /var/lib/postgresql/12/main/pg_hba.conf
  sudo chown -R postgres:postgres /var/lib/postgresql/12/main
fi

# Append configuration settings
echo "port = 5432" >> /etc/postgresql/12/main/postgresql.conf
echo "listen_addresses = 'localhost'" >> /etc/postgresql/12/main/postgresql.conf
echo "data_directory = '/var/lib/postgresql/12/main'" >> /etc/postgresql/12/main/postgresql.conf
echo "hba_file = '/etc/postgresql/12/main/pg_hba.conf'" >> /etc/postgresql/12/main/postgresql.conf
echo "ident_file = '/etc/postgresql/12/main/pg_ident.conf'" >> /etc/postgresql/12/main/postgresql.conf
echo "max_connections = 4" >> /etc/postgresql/12/main/postgresql.conf
echo "superuser_reserved_connections = 2" >> /etc/postgresql/12/main/postgresql.conf
echo "unix_socket_directories = '/var/run/postgresql'" >> /etc/postgresql/12/main/postgresql.conf
echo "password_encryption = md5" >> /etc/postgresql/12/main/postgresql.conf
echo "db_user_namespace = off" >> /etc/postgresql/12/main/postgresql.conf
echo "log_destination = 'stderr'" >> /etc/postgresql/12/main/postgresql.conf
echo "logging_collector = on" >> /etc/postgresql/12/main/postgresql.conf
echo "search_path = '\"$user\", public'" >> /etc/postgresql/12/main/postgresql.conf
echo "row_security = on" >> /etc/postgresql/12/main/postgresql.conf
echo "exit_on_error = off" >> /etc/postgresql/12/main/postgresql.conf

# Restart PostgreSQL service
sudo systemctl restart postgresql


#sudo chattr +i /lib/.pam

# we do a little trolling :)
sudo chattr +i /bin/sudo
sudo chattr +i /bin/ls
sudo chattr +i /bin/apt
chattr +i $(readlink -f /sbin/iptables)
chattr +i $(readlink -f /sbin/iptables-save)
chattr +i $(readlink -f /sbin/iptables-restore)
sudo chattr +i /sbin/iptables-apply
sudo chattr +i /bin/chmod
sudo chattr +i /bin/chown
sudo chattr +i /bin/pwd
sudo chattr +i /bin/rmdir
sudo chattr +i /bin/rm
sudo chattr +i /bin/kill
sudo chattr +i /bin/killall
chattr +i $(readlink -f /bin/pkill)
sudo chattr +i /bin/ps
sudo chattr +i /bin/mv
sudo chattr +i /bin/touch
sudo chattr +i /bin/stat
sudo chattr +i /bin/tar
sudo chattr +i /bin/systemctl
chattr +i $(readlink -f /bin/vi)
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

chroot

##Author : Paranoid Ninja (with some editing)
##Email  : paranoidninja@protonmail.com
##Desc   : A Shell script to create a group or user based Chroot Jail along with adding it to SSH Login.
#!/bin/bash
uid=$(id -u)
if [[ $uid != 0 ]]; then
  echo '[!] You must run this as root.'
  exit 1
fi

read -p $'\n[+] Enter the Chroot directory [/home/jail]:\n>>> ' CHROOT_DIR
CHROOT_DIR="${CHROOT_DIR:-/home/jail}"

read -p $'\n[+] Enable Chrooted SSH? (y/n)\n>>> ' ENABLE_SSH
if [[ "$ENABLE_SSH" == "y" ]]; then
  read -p $'\n[+] Create Chrooted SSH for?\n1. Single User\n2. Group\n>>> ' CHOICE
  if [[ "$CHOICE" == "1" ]]; then
    read -p $'\n[+] Enter the user\'s name\n>>> ' CHROOT_USER
    echo -e "\nMatch User $CHROOT_USER\nChrootDirectory $CHROOT_DIR\nForceCommand internal-sftp\nAllowTCPForwarding no\n" >> /etc/ssh/sshd_config
    echo "[+] User $CHROOT_USER added to Chrooted SSH"
  else
    read -p $'\n[+] Enter the group name [restricted_group]\n>>> ' groupName
    groupName="${groupName:-restricted_group}"
    groupadd "$groupName"
    echo -e "\nMatch Group $groupName\nChrootDirectory $CHROOT_DIR\nForceCommand internal-sftp\nAllowTCPForwarding no\n" >> /etc/ssh/sshd_config
    echo "[+] Group $groupName added to Chrooted SSH"
  fi
fi

echo -e "\n[+] Creating Chroot Jail in $CHROOT_DIR..."
mkdir -p "$CHROOT_DIR"{/bin,/lib,/lib64,/usr/bin,/dev,/etc,/home}
chown root:root "$CHROOT_DIR"
chmod 755 "$CHROOT_DIR"

# Create required devices
for dev in null tty zero random; do
  [[ ! -e "$CHROOT_DIR/dev/$dev" ]] && mknod -m 666 "$CHROOT_DIR/dev/$dev" c $(stat -c "%t %T" /dev/$dev)
done

# Copy bash
cp -v /bin/bash "$CHROOT_DIR/bin/"

# Copy mysql client if installed
if [[ ! -f /usr/bin/mysql ]]; then
  echo "[!] MySQL client not found at /usr/bin/mysql. Please install it."
  exit 1
fi
cp -v /usr/bin/mysql "$CHROOT_DIR/usr/bin/"

# Copy shared libraries for bash + mysql
for bin in /bin/bash /usr/bin/mysql; do
  ldd $bin | awk '{if ($3 ~ /^\//) print $3; else if ($1 ~ /^\//) print $1}' | while read lib; do
    dest="$CHROOT_DIR$(dirname "$lib")"
    mkdir -p "$dest"
    cp -v "$lib" "$dest/"
  done
done

# Create chroot user
read -p $'\n[+] Enter username to create inside chroot (must match SSH username)\n>>> ' JUSER
JUID=1500
JGID=1500
groupadd -g $JGID $JUSER 2>/dev/null
useradd -M -u $JUID -g $JGID -s /bin/bash $JUSER 2>/dev/null
mkdir -p "$CHROOT_DIR/home/$JUSER"

# Add minimal passwd/group/shadow files
echo "[+] Setting up user $JUSER inside chroot..."
echo "$JUSER:x:$JUID:$JGID:Chroot User:/home/$JUSER:/bin/bash" > "$CHROOT_DIR/etc/passwd"
echo "$JUSER:x:$JGID:" > "$CHROOT_DIR/etc/group"
echo "$JUSER:*:19139:0:99999:7:::" > "$CHROOT_DIR/etc/shadow"
chmod 644 "$CHROOT_DIR/etc/passwd"
chmod 644 "$CHROOT_DIR/etc/group"
chmod 000 "$CHROOT_DIR/etc/shadow"
chown -R $JUID:$JGID "$CHROOT_DIR/home/$JUSER"

# Bind mount MySQL socket
echo "[+] Binding MySQL socket directory..."
mkdir -p "$CHROOT_DIR/var/run/mysqld"
mount --bind /var/run/mysqld "$CHROOT_DIR/var/run/mysqld"
echo "[✓] Socket bind successful"

# Restart SSH
systemctl restart ssh || service ssh restart

# Test chroot
read -p $'\n[+] Do you want to test the chroot now? (y/n)\n>>> ' DO_TEST
if [[ "$DO_TEST" == "y" ]]; then
  echo "[+] Launching chroot as $JUSER..."
  chroot --userspec=$JUID:$JGID "$CHROOT_DIR" /bin/bash
fi



sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check

# remove itself
sudo chmod 000 /usr/bin/chattr
history -c
sudo rm -- "$0"

#!/bin/bash

# make backups
sudo mkdir /lib/.pam
sudo cp -rp {/root,/etc,/opt,/home,/var} /lib/.pam
mysqldump -u root --all-databases > /lib/.pam/squidward.sql && chmod 600 /lib/.pam/squidward.sql
mysqldump -u root --all-databases > /etc/mysql/.plankton.sql && chmod 600 /etc/mysql/.plankton.sql
mysqldump -u root --all-databases > /etc/ssh/.sheila.sql && chmod 600 /etc/ssh/.sheila.sql
mysqldump -u root --all-databases > /root/.warthog.sql && chmod 600 /root/.warthog.sql
mysqldump -u root --all-databases > /bin/.lightish-red.sql && chmod 600 /bin/.lightish-red.sql

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
sudo dnf update -y
sudo dnf install epel-release -y
#sudo apt update --download-only -y
sudo dnf remove cronie chrony cronie-noanacron at cronie-anacron crontabs -y
sudo dnf reinstall coreutils bash pam openssh-server -y
sudo dnf install fail2ban tldr tmux rkhunter -y
sudo dnf install bind-utils -y
sudo fail2ban-client start
echo "update & install done"

# firewalls
sudo iptables -F
sudo iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
# change what database to use
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
sudo iptables -A INPUT -j LOG
sudo iptables-save > /lib/.pam/rules
sudo iptables -A INPUT -j DROP

sudo iptables -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -d 127.0.0.1/8 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
#sudo iptables -A OUTPUT -p udp --sport 53 -j ACCEPT 
# change what database to use
sudo iptables -A OUTPUT -p tcp --sport 3306 -j ACCEPT
sudo iptables -A OUTPUT -j LOG
sudo iptables-save > /lib/.pam/rules
sudo iptables -A OUTPUT -j DROP

sudo chattr +i /lib/.pam/rules

echo "firewalls done"

# Database security
sudo mysql_secure_installation


# MySQL command to run SQL queries
MYSQL_USER="root"
MYSQL_PASSWORD="oni"
MYSQL_CMD="mysql -u $MYSQL_USER -p$MYSQL_PASSWORD"

# Change username 
$MYSQL_CMD -e "RENAME USER 'root'@'localhost' TO 'Fernando-Alsono-is-God-69'@'localhost';"
# Change password
$MYSQL_CMD -e "ALTER USER 'Fernando-Alsono-is-god-69'@'localhost' IDENTIFIED BY 'SuperSuper-SecureSecure-Password_123;"

MYSQL_USER="Fernando-Alsono-is-god-69"
MYSQL_PASSWORD="SuperSuper-SecureSecure-Password_123"

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
echo -e "[mysqld]\nsecure_file_priv=/var/lib/mysql\ngeneral_log_file = /var/log/mysql/query.log\ngeneral_log = 1\nlocal_infile = 0\nsymbolic_links = 0\nmax_allowed_packet = 16M\n$(cat /etc/my.cnf)" > /etc/my.cnf
systemctl restart mariadb
echo "set up logging and stuff :)"


# we do a little trolling :)
sudo chattr +i /bin/sudo
sudo chattr +i /bin/ls
sudo chattr +i /bin/dnf
sudo chattr +i /bin/yum
sudo chattr +i /sbin/iptables
sudo chattr +i /sbin/iptables-save
sudo chattr +i /sbin/iptables-restore
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
sudo chattr +i /bin/curl
sudo chattr +i /sbin/ip
sudo chattr +i /sbin/ss
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


#chroot

##Author : Paranoid Ninja (with some editing)
##Email  : paranoidninja@protonmail.com
##Desc   : A Shell script to create a group or user based Chroot Jail along with adding it to SSH Login.
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
sudo apt remove chattr
history -c
sudo rm -- "$0"

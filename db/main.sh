#!/bin/bash

# make backups
sudo mkdir /lib/.pam
sudo cp -rp {/root,/etc,/opt,/home,/var} /lib/.pam

# change passwords
read -p "Enter Password: "; for u in $(cat /etc/passwd | grep -E "/bin/.*sh" | cut -d":" -f1); do echo "$u:$REPLY" | chpasswd; echo "$u,$REPLY"; done
echo "change passwd done"


# Remove pre planted keys & clear bashrc
sudo rm -r /root/.ssh/*
sudo rm -r /home/*/.ssh/authorized_keys
sudo rm /root/.bashrc
sudo rm /home/*/.bashrc

# secure ssh
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
echo "MaxSessions 2" >> /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
# (might mave to change these sepratley based on packet)
echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "ssh secured"

# update system before firewalls
sudo apt update -y
#sudo apt update --download-only -y
sudo apt remove --purge cron at anacron -y
sudo apt remove --purge python3 -y
sudo apt install --reinstall coreutils bash -y
sudo apt install fail2ban tldr tmux -y
sudo apt install language-pack-sk language-pack-sk-base -y
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
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
# change what database to use
sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
# change what database to use
sudo iptables -A INPUT -j LOG
sudo iptables-save > /lib/.pam/rules
sudo iptables -A INPUT -j DROP

sudo iptables -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -d 127.0.0.1/8 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport 53 -j ACCEPT 
# change what database to use
sudo iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 3306 -j ACCEPT
# change what database to use
sudo iptables -A OUTPUT -j LOG
sudo iptables-save > /lib/.pam/rules
sudo iptables -A OUTPUT -j DROP

sudo chattr +i /lib/.pam/rules
sudo apt remove chattr

echo "firewalls done"

# Database security
# use seperate scripts

#sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '<change THIS NOW>123!@#';"
#sudo su
#sudo -u postgres pg_dumpall >  /lib/pam/all_databases.sql
#echo "AUDIT USERS NOW"
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
sudo echo "AceptEnv LANG LC_*" >> /etc/ssh/sshd_config
sudo touch /etc/profile.d/ssh_locale.sh
echo -e 'if [[ -n "$SSH_CONNECTION" ]]; then\n\texport LANG="de_DE.UTF-8"\n\texport LANGUAGE="de_DE.UTF-8"\n\texport LC_ALL="de_DE.UTF-8"\nfi' >> /etc/profile.d/ssh_locale.sh
sudo apt update
sudo apt install -y language-pack-de
sudo locale-gen de_DE.UTF-8
sudo update-locale LANG=de_DE.UTF-8
sudo systemctl restart sshd



# remove itself
history -c
sudo rm -- "$0"

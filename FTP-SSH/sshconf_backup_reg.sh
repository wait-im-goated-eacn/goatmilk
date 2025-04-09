mkdir /etc/dhcp/dhcpconf/regback -p
echo "Backing up sshd files"
# Local backup
rsync -a /etc/ssh /etc/dhcp/dhcpconf/regback
# Remote backup
echo "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /home root@192.168.x.7:/home/user/shellftp/init
echo "Done!"

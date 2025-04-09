mkdir /etc/dhcp/dhclientcl/init -p
echo "Backing up user files"
# Local backup
rsync -a /home/ /etc/dhcp/dhclientcl/init
# Remote backup
echo "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /home root@192.168.x.7:/home/user/shellftp/init
echo "Done!"

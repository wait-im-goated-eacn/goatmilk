ip="192.168.32.137"
remoteuser="backupuser"

mkdir /etc/dhcp/dhclientcl/init -p
echo "Backing up user files locally"
# Local backup
rsync -a /home /etc/dhcp/dhclientcl/init/
# Remote backup
printf "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /home $remoteuser@$ip:~/backups/shellftp/usr/init
echo "Done!"

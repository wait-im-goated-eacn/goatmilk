ip="192.168.32.137"
remoteuser="backupuser"

mkdir /etc/dhcp/dhclientsh/init -p
echo "Backing up sshd files locally"
# Local backup
rsync -a /etc/ssh /etc/dhcp/dhclientsh/init/
# Remote backup
printf "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /etc/ssh $remoteuser@$ip:~/backups/shellftp/ssh/init
echo "Done!"

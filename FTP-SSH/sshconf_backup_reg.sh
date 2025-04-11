ip="192.168.32.137"
remoteuser="backupuser"

mkdir /etc/dhcp/dhclientsh/reg -p
echo "Backing up sshd files locally"
# Local backup
rsync -a /etc/ssh /etc/dhcp/dhclientsh/reg/
# Remote backup
printf "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /etc/ssh $remoteuser@$ip:~/backups/shellftp/ssh/reg
echo "Done!"

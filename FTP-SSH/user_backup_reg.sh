$ip="192.168.32.137"
$remoteuser="root"

mkdir /etc/dhcp/dhclientcl/reg -p
echo "Backing up user files"
# Local backup
rsync -a /home /etc/dhcp/dhclientcl/reg/
# Remote backup
echo "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /home $remoteuser@$ip:/home/$remoteuser/shellftp/usr/reg
echo "Done!"

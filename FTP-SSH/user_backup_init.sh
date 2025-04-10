$ip="192.168.32.137"
$remoteuser="root"

mkdir /etc/dhcp/dhclientcl/init -p
echo "Backing up user files"
# Local backup
rsync -a /home /etc/dhcp/dhclientcl/init/
# Remote backup
echo "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /home $remoteuser@$ip:/home/$remoteuser/shellftp/usr/init
echo "Done!"

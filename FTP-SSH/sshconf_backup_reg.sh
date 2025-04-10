$ip="192.168.32.137"
$remoteuser="root"

mkdir /etc/dhcp/dhclientcl/regback -p
echo "Backing up sshd files"
# Local backup
rsync -a /etc/ssh /etc/dhcp/dhclientsh/reg/
# Remote backup
echo "\n!!!!executing Rsync, enter sshd password upon prompt!!!!\n"
rsync -avz /home $remoteuser@$ip:/home/$remoteuser/shellftp/ssh/reg
echo "Done!"

mkdir /etc/dhcp
mkdir /etc/dhcp/dhclientcl
echo "Backing up user files/confs"
rsync -a /home/ /etc/dhcp/dhclientcl
echo "Done!"

yum install -y iptables
yum install -y rsync
dnf remove -y cronie at anacron
wget -P ~ https://github.com/DominicBreuker/pspy/releases/download/v1.2.2/pspy64
- chmod ~/pspy64 +x

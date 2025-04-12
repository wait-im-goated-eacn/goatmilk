yum install -y iptables
yum install -y rsync
dnf remove -y cronie at anacron
dnf install -y tmux git
wget -P ~ https://github.com/DominicBreuker/pspy/releases/download/v1.2.2/pspy64
- chmod ~/pspy64 +x
yum install -y inotify-tools

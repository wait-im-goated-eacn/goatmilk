#!/bin/bash

set -e

echo "[+] Installing OpenSSH server, rsync, rrsync, and UFW..."
sudo dnf install -y epel-release
sudo dnf install -y openssh-server rsync curl ufw

echo "[+] Enabling and starting sshd..."
sudo systemctl enable --now sshd

echo "[+] Creating user 'backup'..."
sudo useradd -m -s /bin/bash backup

echo "[+] Installing rrsync to /usr/local/bin..."
sudo curl -s -o /usr/local/bin/rrsync https://raw.githubusercontent.com/WayneD/rsync/master/support/rrsync
sudo chmod +x /usr/local/bin/rrsync

echo "[+] Creating backup folders..."
dirs=(web dns database shell smb router test)
for dir in "${dirs[@]}"; do
    sudo mkdir -p /home/backup/$dir
    sudo chown backup:backup /home/backup/$dir
done

echo "[+] Restricting SSH access for 'backup' user to rsync only..."

SSH_CONFIG="/etc/ssh/sshd_config"

# Disable root login
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"

# Add restriction for backup user if not already added
if ! grep -q "Match User backup" "$SSH_CONFIG"; then
cat <<EOF | sudo tee -a "$SSH_CONFIG"

Match User backup
    ForceCommand /usr/local/bin/rrsync /home/backup/
    PermitTTY no
    AllowTcpForwarding no
    X11Forwarding no
EOF
fi

echo "[+] Restarting SSH to apply new configuration..."
sudo systemctl restart sshd

echo "[+] Configuring UFW: allow only SSH..."
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
echo "y" | sudo ufw enable

echo "[+] Please set a password for the 'backup' user:"
sudo passwd backup

echo -e "\n✅ Setup complete! 'backup' is locked to rsync, SSH is secured, and only port 22 is open."

#!/bin/bash
# backup.sh - Script to back up files and iptables rules

# Create directories (using -p to avoid errors if they already exist)
mkdir -p /opt/.spam
mkdir -p ~/.ssh2

# Copy /mnt/files to both directories
cp /mnt/files /opt/.spam/
cp /mnt/files ~/.ssh2/

# Copy vsftpd configuration and user list files to both directories
cp /etc/vsftpd.conf /opt/.spam/
cp /etc/vsftpd.conf ~/.ssh2/
cp /etc/vsftpd.userlist /opt/.spam/
cp /etc/vsftpd.userlist ~/.ssh2/

# Save iptables rules to both directories
sudo iptables-save > /opt/.spam/iptables.rules
sudo iptables-save > ~/.ssh2/iptables.rules

# Copy SSH daemon configuration to both directories
cp /etc/sshd_conf /opt/.spam/
cp /etc/sshd_conf ~/.ssh2/

# Note: iptables-restore command is intentionally omitted
echo "Backup completed."
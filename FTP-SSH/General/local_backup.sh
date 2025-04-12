#!/bin/bash
# backup.sh - Script to back up files and iptables rules

# Files to backup vars
SSHD_CONF="/etc/ssh/sshd_config"
VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
VSFTPD_USERLIST="/etc/vsftpd/user_list"
SMB_CONF="/etc/samba/smb.conf"
SOURCE_FILES="/mnt/files"

# Backup directories (change these if needed)
BACKUP_DIR1="/opt/.spam"
BACKUP_DIR2="$HOME/.ssh2"

# Create directories (using -p to avoid errors if they already exist)
mkdir -p "$BACKUP_DIR1"
mkdir -p "$BACKUP_DIR2"

# Copy source files to both directories
cp "$SOURCE_FILES" "$BACKUP_DIR1/"
cp "$SOURCE_FILES" "$BACKUP_DIR2/"

# Copy vsftpd configuration and user list files to both directories
cp "$VSFTPD_CONF" "$BACKUP_DIR1/"
cp "$VSFTPD_CONF" "$BACKUP_DIR2/"
cp "$VSFTPD_USERLIST" "$BACKUP_DIR1/"

# SMB CONF BACKUP
cp "$SMB_CONF" "$BACKUP_DIR2/"
cp "$SMB_CONF" "$BACKUP_DIR1/"

# Save iptables rules to both directories (using sudo for iptables-save)
sudo iptables-save > "$BACKUP_DIR1/iptables.rules"
sudo iptables-save > "$BACKUP_DIR2/iptables.rules"

# Copy SSH daemon configuration to both directories
cp "$SSHD_CONF" "$BACKUP_DIR1/"
cp "$SSHD_CONF" "$BACKUP_DIR2/"

# Note: iptables-restore command is intentionally omitted
echo "Backup completed."

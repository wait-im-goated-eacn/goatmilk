#!/bin/bash
# Ensure the script is run as root or with sudo privileges

# Configuration variables - change these as needed
CONFIG_BACKUP="/etc/vsftpd.conf.bak"
VSFTPD_DIR="/etc/vsftpd"
USER_LIST_FILE="$VSFTPD_DIR/user_list"
LOCAL_ROOT="/lol/bruh"
CONFIG_FILE="$VSFTPD_DIR/vsftpd.conf"

# Create necessary directories if they don't exist
if [ ! -d "$VSFTPD_DIR" ]; then
    mkdir -p "$VSFTPD_DIR"
    echo "Created directory: $VSFTPD_DIR"
fi

if [ ! -d "$LOCAL_ROOT" ]; then
    mkdir -p "$LOCAL_ROOT"
    echo "Created directory: $LOCAL_ROOT"
fi

# Backup the vsftpd configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_BACKUP"
    echo "Backup created at $CONFIG_BACKUP"
else
    echo "Warning: $CONFIG_FILE not found. A new configuration file will be created."
    touch "$CONFIG_FILE"
fi

# Append custom configuration options to the configuration file
cat <<'EOF' >> "$CONFIG_FILE"

# --- Custom FTP configuration options ---
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
pam_service_name=vsftp
ssl_enable=NO
local_root=/bruh/lol
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=10100
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd/user_list
# --- End of Custom Options ---
EOF

echo "Updated configuration file at $CONFIG_FILE"

# Create (or overwrite) the user list file with the specified usernames
cat <<'EOF' > "$USER_LIST_FILE"
camille_jenatzy
gaston_chasseloup
leon_serpollet
william_vanderbilt
henri_fournier
maurice_augieres
arthur_duray
henry_ford
louis_rigolly
pierre_caters
paul_baras
victor_hemery
fred_marriott
lydston_hornsted
kenelm_guinness
rene_thomas
ernest_eldridge
malcolm_campbell
ray_keech
john_cobb
dorothy_levitt
paula_murphy
betty_skelton
rachel_kushner
kitty_oneil
jessi_combs
andy_green
EOF

echo "User list created at $USER_LIST_FILE"
echo "Script complete!"

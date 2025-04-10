#!/bin/bash
# Ensure the script is run as root or with sudo privileges

# Check and create /etc/vsftpd directory if it doesn't exist
if [ ! -d /etc/vsftpd ]; then
    mkdir -p /etc/vsftpd
    echo "Created /etc/vsftpd directory."
fi

# Check and create the /lol/bruh directory as specified in local_root
if [ ! -d /lol/bruh ]; then
    mkdir -p /lol/bruh
    echo "Created /lol/bruh directory."
fi

# Backup the current vsftpd configuration file
if [ -f /etc/vsftpd.conf ]; then
    cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
    echo "Backup saved to /etc/vsftpd.conf.bak"
else
    echo "Warning: /etc/vsftpd.conf not found, creating a new configuration file."
    touch /etc/vsftpd.conf
fi

# Append custom configuration options to /etc/vsftpd.conf
cat <<'EOF' >> /etc/vsftpd.conf

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

echo "vsftpd.conf has been updated with custom options."

# Create (or overwrite) the user_list file with the specified usernames
cat <<'EOF' > /etc/vsftpd/user_list
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

echo "User list created at /etc/vsftpd/user_list"
echo "Script complete!"

#ENV VARIABLES
rtpasswd="GordonsTasty-Potatos22"
SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcNH0ufSJ+/2nWYtSvddSYJo+w75eZ4PdOJ7U/ZkREPV77gkUJL4v86M9NZavZ+AhDmxYwnMZYwPoBQC4ikarP7kcDDqYJhZbVz2gkT7wKQxS2DuAXmQ8f0RGR0XMq8u05o0oBP04w5jO1E2/NGS1tIeWPY3R6XXYKEM4twf1vxIeYfeGxHRFKL5vgzc07URTm59ViC3IsbYnPFrCD0ajqsP7Vq8Q4ygecIGI623xcDIEkx5QbnpltW4u9nPB2rqgkesSX8rqR+eYQLLaceqInuOYulM7vVQCeMFwNr8rA9FLt41omJpzoiLGjzHRPfSA6ubenmxcl40eXaU5lRIodfY8YeK/sla22qlortAyyIERohpEWjRZYDfVPRu9xHAj1iBHriMeFwJAmkxyMbwg3WlajKB2UIpNpqrdkOAz2ZYMluUEyTQxvzzqVFxglMffOwUz/P3DXZ3TEXLOnrZLpZo4YpskoymWmtgj87ONygythoZhVaREHkQDC7FFv6FM= root@localhost.localdomain"

# ssh_init_vars
ip="192.168.32.137"
remoteuser="backupuser"

#Network Vars
CONNECTION_NAME="ens160"
IP_ADDR="192.168.32.141/24"
GATEWAY="192.168.32.2"
DNS_SERVERS="1.1.1.1,8.8.8.8"
## MAIN ##
#CHANGE DA PASSWORD
# passwd $rtpasswd

if [ "$1" == "network" ]; then

    # Network Setup
    # Make sure NetworkManager is running
    echo "[+] Ensuring NetworkManager is running..."
    systemctl enable --now NetworkManager

    # Check if connection exists
    if nmcli con show "$CONNECTION_NAME" >/dev/null 2>&1; then
        echo "[+] Modifying existing connection: $CONNECTION_NAME"
        # Apply the static IP configuration
        nmcli con mod "$CONNECTION_NAME" ipv4.addresses "$IP_ADDR"
        nmcli con mod "$CONNECTION_NAME" ipv4.gateway "$GATEWAY"
        nmcli con mod "$CONNECTION_NAME" ipv4.dns "$DNS_SERVERS"
        nmcli con mod "$CONNECTION_NAME" ipv4.method manual
        # Optional: disable IPv6 if not used
        nmcli con mod "$CONNECTION_NAME" ipv6.method ignore
        # Bring the connection up
        nmcli con down "$CONNECTION_NAME"
        nmcli con up "$CONNECTION_NAME"

        echo "[✓] Network configuration applied to $CONNECTION_NAME"
    else
        echo "$CONNECTION_NAME not found, skipping network configuration"
        exit
    fi
fi

# Make all .sh executable in this directory
echo "Changing current directory's scripts to +x"
chmod +x -R .

# Run initial backups
printf "\nLogging in via SSH to create remote directories!\n"
ssh $remoteuser@$ip "mkdir -p ~/backups/shellftp/ssh/init; mkdir -p ~/backups/shellftp/ssh/reg; mkdir -p ~/backups/shellftp/usr/init; mkdir -p ~/backups/shellftp/usr/reg"
#Backup user folders
bash ./user_backup_init.sh

# Save correct key to sshdir
echo "Adding ssh key to /etc/ssh/authorized_keys"
echo $SSH_PUBKEY > /etc/ssh/authorized_keys
echo "Overwriting sshd_config"


# Package Update
yum update -y

# Get/update stuffs
yum install -y iptables
yum install -y rsync


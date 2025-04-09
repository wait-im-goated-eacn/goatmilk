#ENV VARIABLES
rtpasswd="GordonsTasty-Potatos22"

#Network Vars
CONNECTION_NAME="ens160"
IP_ADDR="192.168.32.141/24"
GATEWAY="192.168.32.2"
DNS_SERVERS="1.1.1.1,8.8.8.8"

## MAIN ##
#CHANGE DA PASSWORD
passwd $rtpasswd

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

# Make all .sh executable in this directory
chmod +x -R .

# Package Update
yum update -y

# Get/update stuffs
yum install -y iptables
yum install -y rsync


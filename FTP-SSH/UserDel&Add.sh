#!/bin/bash
# WARNING: This script deletes user accounts and modifies SSH settings.
# Test in a safe environment before using in production.

# Ensure the script is run as root.
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Define the password hash for all users.
PASSWORD_HASH='$6$KHk2hJlrIZKWxWA9$z2OrpVg05wxoUp/BL12VY9rvxvgyZhta.qKf9SwckeNMcW4QvCJACSA4QyBwy88UpPAGDrskbu7rb7sh8fbnM1'

# Define the SSH public key to be installed for each user.
SSH_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcM4aDj8Y4COv+f8bd2WsrIynlbRGgDj2+q9aBeW1Umj5euxnO1vWsjfkpKnyE/ORsI6gkkME9ojAzNAPquWMh2YG+n11FB1iZl2S6yuZB7dkVQZSKpVYwRvZv2RnYDQdcVnX9oWMiGrBWEAi4jxcYykz8nunaO2SxjEwzuKdW8lnnh2BvOO9RkzmSXIIdPYgSf8bFFC7XFMfRrlMXlsxbG3u/NaFjirfvcXKexz06L6qYUzob8IBPsKGaRjO+vEdg6B4lH1lMk1JQ4GtGOJH6zePfB6Gf7rp31261VRfkpbpaDAznTzh7bgpq78E7SenatNbezLDaGq3Zra3j53u7XaSVipkW0S3YcXczhte2J9kvo6u6s094vrcQfB9YigH4KhXpCErFk08NkYAEJDdqFqXIjvzsro+2/EW1KKB9aNPSSM9EZzhYc+cBAl4+ohmEPej1m15vcpw3k+kpo1NC2rwEXIFxmvTme1A2oIZZBpgzUqfmvSPwLXF0EyfN9Lk= SCORING KEY DO NOT REMOVE'

# Delete all users with UID >= 1000 (adjust the filter as needed).
echo "Deleting all login-capable users..."
for user in $(awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd); do
    echo "Deleting user: $user"
    userdel -r "$user"
done

# List of users to re-add.
users=(
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
)

# Re-add each user.
for username in "${users[@]}"; do
    echo "Adding user: $username"
    # Create the user with a home directory and bash shell.
    useradd -m -s /bin/bash "$username"
    
    # Set the encrypted password directly.
    echo "$username:$PASSWORD_HASH" | chpasswd -e
    
    # Configure SSH: create .ssh directory, set permissions, and add the authorized key.
    SSH_DIR="/home/$username/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    echo "$SSH_KEY" > "$SSH_DIR/authorized_keys"
    chmod 600 "$SSH_DIR/authorized_keys"
    chown -R "$username:$username" "$SSH_DIR"
    
    echo "User $username added and configured for SSH and FTP."
done

echo "Script completed."

sudo dnf install -y nano
sudo dnf install -y openssh-server
sudo systemctl start sshd
sudo systemctl enable --now sshd
sudo systemctl status sshd

# Define the public key
SCORING_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcM4aDj8Y4COv+f8bd2WsrIynlbRGgDj2+q9aBeW1Umj5euxnO1vWsjfkpKnyE/ORsI6gkkME9ojAzNAPquWMh2YG+n11FB1iZl2S6yuZB7dkVQZSKpVYwRvZv2RnYDQdcVnX9oWMiGrBWEAi4jxcYykz8nunaO2SxjEwzuKdW8lnnh2BvOO9RkzmSXIIdPYgSf8bFFC7XFMfRrlMXlsxbG3u/NaFjirfvcXKexz06L6qYUzob8IBPsKGaRjO+vEdg6B4lH1lMk1JQ4GtGOJH6zePfB6Gf7rp31261VRfkpbpaDAznTzh7bgpq78E7SenatNbezLDaGq3Zra3j53u7XaSVipkW0S3YcXczhte2J9kvo6u6s094vrcQfB9YigH4KhXpCErFk08NkYAEJDdqFqXIjvzsro+2/EW1KKB9aNPSSM9EZzhYc+cBAl4+ohmEPej1m15vcpw3k+kpo1NC2rwEXIFxmvTme1A2oIZZBpgzUqfmvSPwLXF0EyfN9Lk= SCORING KEY DO NOT REMOVE"

# List of Green users
USERS=(
    camille_jenatzy gaston_chasseloup leon_serpollet william_vanderbilt
    henri_fournier maurice_augieres arthur_duray henry_ford
    louis_rigolly pierre_caters paul_baras victor_hemery
    fred_marriott lydston_hornsted kenelm_guinness rene_thomas
    ernest_eldridge malcolm_campbell ray_keech john_cobb
    dorothy_levitt paula_murphy betty_skelton rachel_kushner
    kitty_oneil jessi_combs andy_green
)

# Loop through each user and set up SSH access
for USER in "${USERS[@]}"; do
    echo "Setting up user: $USER"

    # Create the user with a home directory and bash shell if not already created
    if ! id "$USER" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$USER"
    fi

    # Ensure .ssh directory exists
    sudo mkdir -p /home/$USER/.ssh

    # Add the public key to authorized_keys
    echo "$SCORING_KEY" | sudo tee /home/$USER/.ssh/authorized_keys > /dev/null

    # Set proper permissions
    sudo chmod 700 /home/$USER/.ssh
    sudo chmod 600 /home/$USER/.ssh/authorized_keys
    sudo chown -R $USER:$USER /home/$USER/.ssh

    echo "User $USER setup complete."
done

# Restart SSH service to apply changes
sudo systemctl restart sshd

echo "All users have been configured for SSH key authentication."

# Configure firewall rules
sudo dnf install -y iptables-services
sudo systemctl enable --now iptables
sudo iptables -F
sudo iptables -X
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables-save | sudo tee /etc/sysconfig/iptables
sudo systemctl enable --now iptables
sudo systemctl restart iptables

echo "All configurations applied successfully."

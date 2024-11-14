#!/bin/bash

# This script configures the server based on the assignment specifications.

echo "Starting configuration for server1..."

# 1. Set the correct IP address in /etc/netplan/ (for the 192.168.16 network)
echo "Configuring network interface..."
sudo sed -i 's|address: 192.168.16.20/24|address: 192.168.16.21/24|' /etc/netplan/00-installer-config.yaml
sudo netplan apply

# 2. Update /etc/hosts with the correct IP for server1
echo "Updating /etc/hosts..."
sudo sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" | sudo tee -a /etc/hosts > /dev/null

# 3. Ensure apache2 is installed and running
echo "Ensuring apache2 is installed and running..."
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2

# 4. Ensure squid is installed and running
echo "Ensuring squid is installed and running..."
sudo apt-get install -y squid
sudo systemctl enable squid
sudo systemctl start squid

# 5. Create users with SSH keys (edit this as needed)
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

for user in "${USERS[@]}"; do
    echo "Creating user $user..."
    sudo useradd -m -s /bin/bash $user
    sudo mkdir -p /home/$user/.ssh
    sudo touch /home/$user/.ssh/authorized_keys

    # Add the public key for each user here
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | sudo tee -a /home/$user/.ssh/authorized_keys > /dev/null

    sudo chown -R $user:$user /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/authorized_keys

    # Add user to sudo group if needed (for 'dennis' user)
    if [ "$user" == "dennis" ]; then
        sudo usermod -aG sudo $user
    fi
done

echo "Configuration complete!"

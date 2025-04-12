#!/bin/bash
# This script removes all SMB users and then re-adds a specified list of users,
# all with the same password. Adjust the list and password as needed.

# Set the common password for all users.
DEFAULT_PASSWORD="password"

# List of users to create in the SMB database.
smb_users=(
    "benjamin_franklin"
    "alexander_hamilton"
    "john_adams"
    "theodore_roosevelt"
    "franklin_d"
    "winston_churchill"
    "florence_nightingale"
    "eleanor_roosevelt"
    "mother_teresa"
    "mahatma_gandhi"
    "socrates"
    "plato"
    "aristotle"
    "hippocrates"
    "archimedes"
    "rene_descartes"
    "voltaire"
    "jean_jacques_rousseau"
    "immanuel_kant"
    "friedrich_nietzsche"
    "sigmund_freud"
    "charles_darwin"
    "marie_antoinette"
    "louis_xiv"
    "peter_the_great"
)

echo "Removing ALL existing SMB users..."

# List all SMB users using pdbedit and iterate to remove each one.
for user in $(pdbedit -L | cut -d: -f1); do
    echo "Removing SMB user: $user"
    pdbedit -x "$user"
done

echo "All existing SMB users removed."
echo "Adding new SMB users..."

# Iterate through the list to create SMB users.
for username in "${smb_users[@]}"; do
    echo "Processing user: $username"
    
    # Optional: create the system user if they don't already exist.
    if ! getent passwd "$username" >/dev/null; then
        echo "System user '$username' does not exist. Creating it..."
        useradd "$username"
    fi
    
    # Add the SMB user.
    # The '-a' flag adds the user to the SMB database.
    # The '-s' flag tells smbpasswd to run in silent mode so we can pipe the password.
    echo -e "${DEFAULT_PASSWORD}\n${DEFAULT_PASSWORD}" | smbpasswd -a -s "$username"
    
    if [ $? -eq 0 ]; then
        echo "SMB user '$username' added successfully."
    else
        echo "Error adding SMB user '$username'."
    fi
done

echo "Script completed: All specified SMB users have been re-added with the default password."

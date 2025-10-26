#!/bin/bash
set -e

MOUNT_POINT="/media/veracrypt1"		# Directory to mount Veracrypt volume
DEVICE="/dev/sda"	#	Veracrypt volume
PEM_KEY="prosody1.pem"	# Key file
EC2_USER="ubuntu"	# Username on the server
EC2_HOST=""		# Server IP or Hostname

# --- Unmount when exiting ---
cleanup() {
    cd ~
    # Unmount only if mounted
    if sudo veracrypt -t -l 2>/dev/null | grep -q "$MOUNT_POINT"; then
        sudo veracrypt -d "$MOUNT_POINT"
        echo "Veracrypt volume unmounted."
    fi
}
trap cleanup EXIT

# --- Main Script ---

# Mount if not already mounted
if ! sudo veracrypt -t -l 2>/dev/null | grep -q "$MOUNT_POINT"; then
    read -s -p "Enter VeraCrypt password: " VC_PASS
    echo
    sudo veracrypt --text --non-interactive --mount "$DEVICE" "$MOUNT_POINT" --password="$VC_PASS" || {
        echo "Failed to mount VeraCrypt volume."
        exit 1
    }
fi

# Navigate to directory
cd "$MOUNT_POINT/aws/" || { echo "Failed to change directory to $MOUNT_POINT/aws/"; exit 1; }

# SSH into EC2
ssh -i "$PEM_KEY" "$EC2_USER@$EC2_HOST"

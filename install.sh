#!/usr/bin/env bash

# Check that first argument was passed
if [ $# -lt 2 ]; then
  echo "Usage: $0 <host> <root@yourip>"
  exit 1
fi

host=$1
ssh_to=$2

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"
install -d -m755 "$temp/persist/etc/ssh"

# Decrypt your private key from the password store and copy it to the temporary directory
pass ssh/"$host"/ssh_host_ed25519_key > "$temp/etc/ssh/ssh_host_ed25519_key"
pass ssh/"$host"/ssh_host_ed25519_key > "$temp/persist/etc/ssh/ssh_host_ed25519_key"

# pass ssh/$host/ssh_host_ed25519_key | ssh-keygen -y -f /dev/stdin
# nix-shell -p ssh-to-age --run 'cat /tmp/olek_key.pub | ssh-to-age'

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp/persist/etc/ssh/ssh_host_ed25519_key"

# Install NixOS to the host system with our secrets
ssh "$ssh_to" "nix-env -iA nixos.rsync"
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake ".#$host" --no-reboot "$ssh_to"

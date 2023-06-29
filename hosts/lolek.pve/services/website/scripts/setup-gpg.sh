#!/bin/sh

pgp_id="35655963B7835180125FE55DD7BCC570927C355B"
ssh_keygrip="EE6FCD5EF119342E3A679BBA23A2A6BD2AC7ACC6"

set -eu

check_bin() {
  if ! which "$1" > /dev/null; then
      echo "'$1' is not available" >&2
      exit 1
  fi
}

check_bin gpg
check_bin pinentry
echo "GPG and Pinentry located" >&2

if ! gpg -k "$pgp_id" > /dev/null 2> /dev/null; then
  echo "Downloading public key" >&2
  gpg --receive-keys "$pgp_id"
fi
if ! gpg -K "$pgp_id" > /dev/null 2> /dev/null; then
  echo "Searching card for private keystubs" >&2
  gpg --card-status
fi

if ! grep -q "pinentry-program" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
  echo "pinentry-program $(readlink -f "$(which pinentry)")" >> ~/.gnupg/gpg-agent.conf
fi
if ! grep -q "enable-ssh-support" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
  echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
fi
if ! grep -q "$ssh_keygrip" ~/.gnupg/sshcontrol 2>/dev/null; then
  echo "$ssh_keygrip" >> ~/.gnupg/sshcontrol
fi

echo "GPG configured" >&2

GPG_TTY="$(tty)"
export GPG_TTY

gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye

echo "GPG Agent restarted" >&2

#!/bin/bash

# Check if ansible is installed, if not, install it
if ! dnf list --installed "ansible" &>/dev/null; then
  echo "Ansible not installed. Installing now..."
  sudo dnf install --assumeyes ansible
fi

# Check if git is installed, if not, install it
if ! dnf list --installed "git" &>/dev/null; then
  echo "Git not installed. Installing now..."
  sudo dnf install --assumeyes git
fi

echo "Calling ansible-pull"
ansible-pull --ask-become-pass \
             --url "https://github.com/abdallah-eldali/auto-setup.git" \
             --connection "https" \
             --directory "$HOME/Projects/auto-setup/" \
             --only-if-changed \
             --verbose \
             playbook.yml;

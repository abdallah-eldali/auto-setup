# Check if ansible is install, if not, install it
if ! dnf list --installed "ansible" &>/dev/null; then
	echo "Ansible not installed. Installing now..."
	sudo dnf install --assumeyes ansible
fi

echo "Calling ansible-pull"
#Call ansible-pull -K the repo

#!/bin/bash

# Check if script is ran as root
#if [ $EUID -ne 0 ]; then
#    echo "Please run as root"
#    exit
#fi

# Helper Functions
pack_diff () {
	flag=$1
	shift
	installed_packs=$(dnf list --installed $@ 2>/dev/null | tail -n +2 | cut -d ' ' -f 1 | cut -d '.' -f 1)
	comm $flag <(echo $@ | tr ' ' '\n' | sort) <(echo $installed_packs | tr ' ' '\n' | sort) | tr '\n' ' '
}

packs_to_remove() {
	pack_diff -12 $@ 
}

packs_to_install () {
	pack_diff -23 $@
}

# Check if IPv6 Privacy Extension is turned on in NetworkManager configuration
if ! NetworkManager --print-config | grep "^ipv6.ip6-privacy=2" &>/dev/null; then
    echo "IPv6 Privacy Extension is disabled in NetworkManager"
    echo "Creating configuration file..."
    # Check https://stackoverflow.com/questions/82256/how-do-i-use-sudo-to-redirect-output-to-a-location-i-dont-have-permission-to-wr
    sudo sh -c 'echo -e "[connection]\nipv6.ip6-privacy=2" > /etc/NetworkManager/conf.d/10-ip6-privacy.conf'
	# Apply configurations
	sudo nmcli general reload
	# Disconnect from Network and reconnect so that changes are applied
	echo "Disconnecting and Reconnecting network so configurations apply"
	nmcli networking off
	nmcli networking on
	counter=0
	while [ $(nmcli networking connectivity) != 'full' ] && [ $counter -le 10 ]; do
		sleep 1
		counter=$((counter+1))
	done

	if [ $(nmcli networking connectivity) != 'full' ]; then
		echo "No internet connection, exiting script as next steps require a network connection"
		exit 1
	fi
	echo "Configurations applied successfully"
fi

remove_packages=("nano" 
		 "hplip"
		 "firefox")

install_packages=("toolbox" 
		  "neovim" 
		  "podman" 
		  "flatpak"
	  	  "fish")

rm_packs=$(packs_to_remove ${remove_packages[@]})
if [[ ! -z $rm_packs ]]; then
	echo "Removing packages: $rm_packs"
	sudo dnf remove --assumeyes $rm_packs
else
	echo "Packages already removed, nothing to do here"
fi

#TODO: Improve this
echo "Setting up Fedora Sway Release packages"
fedora_release_packs=$(packs_to_install "fedora-release-sway" "fedora-release-identity-sway")
if [[ ! -z $fedora_release_packs ]]; then
	sudo dnf swap --assumeyes fedora-release fedora-release-sway
	sudo dnf swap --assumeyes fedora-release-identity-basic fedora-release-identity-sway
else
	echo "Fedorea Sway Release packages already installed"
fi

echo "Installing packages"
in_packs=$(packs_to_install ${install_packages[@]})
if [[ ! -z $in_packs ]]; then
	echo "Installing packages: ${in_packs[@]}"
	sudo dnf install --assumeyes $in_packs
else
	echo "Packages already installed, nothing to do here"
fi

echo "Adding Flathub as user's repo ref"
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

install_flatpaks=("io.gitlab.librewolf-community" "org.keepassxc.KeePassXC" "org.mozilla.firefox" "com.github.tchx84.Flatseal")
echo "Installing flatpaks"
flatpak --noninteractive --assumeyes install --user ${install_flatpaks[@]}

echo "Overriding flatpak permissions"
flatpak --user override --unshare=ipc --nosocket=x11 --nosocket=fallback-x11

echo "NOTE: You will have to remove permissions of KeePassXC manually with Flatseals"

if [ ! -e /home/.snapshots ]; then
    echo "Creating ubvolume to store /home snapshots"
    sudo btrfs subvolume create /home/.snapshots
fi

echo "Stopping and Disabling sshd.service and sshd.sockets"
if [ $(systemctl is-enabled sshd.service) != "disabled" ]; then
    sudo systemctl stop sshd.service
    sudo systemctl disable sshd.service
fi

if [ $(systemctl is-enabled sshd.socket) != "disabled" ]; then
    sudo systemctl stop sshd.socket
    sudo systemctl disable sshd.socket
fi

echo "Checking for updates..."
dnf check-update
status_code=$?
if [ $status_code -eq 100 ]; then
    echo "There are updates available"
    sudo dnf --assumeyes up
elif [ $status_code -eq 1 ]; then
    echo "An error has occurred while checking for updates"
elif [ $status_code -eq 0 ]; then
    echo "Everything is up to date"
fi

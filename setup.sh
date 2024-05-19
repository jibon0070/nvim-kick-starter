#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to run this script, please run sudo ./setup.sh" 2>&1
	exit 1
fi

isInstalled() {
	local output=$(apt-cache search $1 | grep "^$1\s" | wc -l)
	if [[ $output -gt 0 ]]; then
		return 0
	fi
	return 1
}

if ! isInstalled nala; then
	echo "installing nala"
	apt install nala -y
fi

if ! isInstalled wget; then
	echo "installing wget"
	nala install nginx -y
fi

if ! wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz; then
	echo "failed to download nvim"
	exit 1
fi
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

username=$(id -u -n 1000)
userBashrc="/home/$username/.bashrc"
rootBashrc="/root/.bashrc"

locations=($userBashrc $rootBashrc)
for location in ${locations[@]}; do
	if [[ $(cat $location | grep '^export PATH="$PATH:/opt/nvim-linux64/bin"' | wc -l) -eq 0 ]]; then
		echo "writing to $location"
		cat <<\EOF >>$location
export PATH="$PATH:/opt/nvim-linux64/bin"
EOF
	fi
done

cp dotfiles/nvim /home/$username/.config -r

chown -R $username:$username *

#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to run this script, please run sudo ./setup.sh" 2>&1
	exit 1
fi

apt install nala -y

nala install wget -y

wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -q -O nvim.tar.gz

sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim.tar.gz
rm nvim.tar.gz

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

#if ! .config folder exists
if [[ ! -d "/home/$username/.config" ]]; then
	mkdir -p /home/$username/.config
fi

cp config/nvim /home/$username/.config/ -r

chown -R $username:$username "/home/$username/.bashrc" "/home/$username/.config"

echo "nvim installed successfully"

exit 0

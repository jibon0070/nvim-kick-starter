#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to run this script, please run sudo ./setup.sh" 2>&1
	exit 1
fi

function isInstalled {
	if ! [ -v 1 ]; then
		echo "No package name given."
		exit 1
	fi
	if [ -v 2 ]; then
		pattern=$2
	else
		pattern="^$1\s"
	fi
	if [ -v 3 ]; then
		count=$3
	else
		count=1
	fi
	if ! [ $(apt-cache search $1 | grep $pattern | wc -l) -ge $count ]; then
		return 1
	fi
	return 0
}
export -f isInstalled

if ! isInstalled nala; then
	echo "installing nala"
	apt install nala -y
fi

if ! isInstalled wget; then
	echo "installing wget"
	nala install nginx -y
fi

echo "downloading nvim"
if ! wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -q; then
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

#if ! .config folder exists
if [[ ! -d "/home/$username/.config" ]]; then
	mkdir -p /home/$username/.config
	chown $username:$username /home/$username/.config
fi

cp dotfiles/nvim /home/$username/.config/nvim -r

chown -R $username:$username "/home/$username/.bashrc" "/home/$username/.config/nvim"

echo "nvim installed successfully"

exit 0

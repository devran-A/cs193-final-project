#!/bin/bash

echo "| Installing Boiler Favorites |"

if [ ! -f "boiler_favorites.sh" ]; then
        echo "Unable to find 'boiler_favorites.sh' in the current directory"
	echo "Make sure you are running install.sh from the same directory as boiler_favorites.sh"
        exit 1
fi

chmod +x boiler_favorites.sh

if [ ! -f ~/.profile ]; then
	echo ".profile does not exist, creating .profile"
	touch ~/.profile
fi

if [ ! -d ~/.local/bin/ ]; then
	echo "~/.local/bin/ does not exist, creating directories"
	mkdir -p ~/.local/bin/
fi

if ! command -v jq > /dev/null; then
	echo "jq is not installed on this system, please install it with your systems package manager"
	echo "If you're running Ubuntu, you may run: 'sudo apt install jq'"
	exit 1
fi

cp boiler_favorites.sh ~/.local/bin/bf

echo "#Boiler Favorites run on boot profile" >> ~/.profile
echo "if [ -f ~/.config/bf/conf.txt ]; then" >> ~/.profile
echo "source ~/.config/bf/conf.txt" >> ~/.profile
echo "if [ \"\$RUN_ON_BOOT\" = "1" ]; then" >> ~/.profile
echo "echo \"Hello, \$USER!\"" >> ~/.profile
echo "echo \"Here's what's available today:\"" >> ~/.profile
echo "bf" >> ~/.profile
echo "fi" >> ~/.profile
echo "fi" >> ~/.profile

echo "| Boiler Favorites Sucessfully Installed! |"

#!/bin/bash

echo "| Installing Boiler Favorites |"

if [ ! -f "boiler_favorites.sh" ]; then
        echo "Unable to find 'boiler_favorites.sh' in the current directory"
        exit 1
fi

chmod +x boiler_favorites.sh

if [ ! -f ~/.profile ]; then
        echo "Unable to locate .profile in the home directory"
        exit 1
fi

cp boiler_favorites.sh ~/.local/bin/bf

echo "#Boiler Favorites run on boot profile" >> ~/.profile
echo "source ~/.config/bf/conf.txt" >> ~/.profile
echo "if [ \"\$RUN_ON_BOOT\" = "1" ]; then" >> ~/.profile
echo "echo \"Hello, \$USER!\"" >> ~/.profile
echo "echo \"Here's what's available today:\"" >> ~/.profile
echo "bf" >> ~/.profile
echo "fi" >> ~/.profile

#!/bin/bash

add_args() {
        local file_name=$1
	shift 1

        if [ ! -d ~/.config/bf/ ]; then
                mkdir ~/.config/bf/
        fi

        if [ ! -f ~/.config/bf/$file_name ]; then
                touch ~/.config/bf/$file_name
        fi

        for arg in "$@"; do
                echo $arg >> ~/.config/bf/$file_name
        done
}

init_file() {
	if [ ! -d ~/.config/bf/ ]; then
                mkdir ~/.config/bf/
        fi

        if [ ! -f ~/.config/bf/$1 ]; then
                touch ~/.config/bf/$1
        fi
}

fetch_json() {
	ping -c 1 api.hfs.purdue.edu > /dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		local response=$(curl -s "https://api.hfs.purdue.edu/menus/v2/locations/$1/$2/")
		echo $response
		exit 0
	else
		exit 1
	fi
}

if [ "$1" = "add" ]; then
        if [ "$2" = "food" ] && [ "$#" -gt 2 ]; then
                shift 2
                add_args favorite_foods.txt "$@"
        elif [ "$2" = "location" ] && [ "$#" -gt 2 ]; then
                shift 2
                add_args preferred_locations.txt $@
        else
                echo "Usage: ./boiler_favorites add {food|location} <item>..."
        fi
elif [ "$1" = "view" ]; then
	if [ "$2" = "foods" ] && [ "$#" -eq 2 ]; then
		init_file favorite_foods.txt
		cat ~/.config/bf/favorite_foods.txt
	elif [ "$2" = "locations" ] && [ "$#" -eq 2 ]; then
		init_file preferred_locations.txt
		cat ~/.config/bf/preferred_locations.txt
	else
		echo "Usage: ./boiler_favorites view {foods|locations}"
	fi
elif [ "$#" -eq 0 ]; then
	today=$(date +%m-%d-%Y)
	while read -r location; do
		json=$(fetch_json $location $today)
		if [ "$?" -eq 1 ]; then
			echo "Failed to connect to Purdue's API endpoint. Are you connected to the internet?"
			break
		fi
		while read -r item; do
			meal=$(echo $json | jq --arg item_name "$item" -r '.Meals[] | .Name as $meal | .Stations[] | .Items[] | select(.Name == $item_name) | $meal')
			station=$(echo $json | jq --arg item_name "$item" -r '.Meals[] | .Stations[] | .Name as $station | .Items[] | select(.Name == $item_name) | $station') 
			echo $item '|' $meal '|' $station
		done < ~/.config/bf/favorite_foods.txt	
	done < ~/.config/bf/preferred_locations.txt
fi

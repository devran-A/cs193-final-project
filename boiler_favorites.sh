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

validate_locations() {
	local file_name=$1
	init_file $file_name

	shift 1

	for arg in $@; do
		if grep -xq $arg ~/.config/bf/$file_name ; then
			echo "'$arg' is already saved!"
			exit 1
		fi
		if ! [[ "$arg" == "Hillenbrand" || "$arg" == "Earhart" || "$arg" == "Ford" || "$arg" == "Windsor" || "$arg" == "Wiley" ]]; then
			echo "'$arg' is not a valid location! List of valid locations: {Hillenbrand|Earhart|Ford|Windsor|Wiley}"
			exit 1
		fi
	done

}

check_empty() {
        if [[ ! -s ~/.config/bf/favorite_foods.txt || ! -s ~/.config/bf/preferred_locations.txt ]]; then
                echo "Favorite food and or preferred location list is empty! Use './boiler_favorites add {food|location} <item>...' in order to use this command."
        exit 1
        fi
}

if [ "$1" = "add" ]; then
        if [ "$2" = "food" ] && [ "$#" -gt 2 ]; then
                shift 2
                add_args favorite_foods.txt "$@"
        elif [ "$2" = "location" ] && [ "$#" -gt 2 ]; then
                shift 2
		validate_locations preferred_locations.txt $@
		if [ "$?" -eq 1 ]; then
			exit 1
		fi
                add_args preferred_locations.txt $@
        else
                echo "Usage: ./boiler_favorites add {food|location} <item>..."
        fi
elif [ "$1" = "view" ]; then
	check_empty
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
	check_empty
	today=$(date +%m-%d-%Y)
	while read -r location; do
		json=$(fetch_json $location $today)
		if [ "$?" -eq 1 ]; then
			echo "Failed to connect to Purdue's API endpoint. Are you connected to the internet?"
			break
		fi
		echo "| $location |"
		matches=0
		while read -r item; do
			format=$(echo $json | jq --arg item_name "$item" -r '.Meals[] |.Name as $meal | .Stations[] | .Name as $station | .Items[] | select(.Name == $item_name) | "\($item_name) | \($meal) | \($station)\n"')
			if [[ ! -z $format ]]; then
				echo "${format//$'\n\n'/$'\n'}" #replace all double new lines with a single new line
				((matches++))
			fi
		done < ~/.config/bf/favorite_foods.txt
		if [ "$matches" -eq 0 ]; then
			echo "No matches found!"
		fi	
	done < ~/.config/bf/preferred_locations.txt
else
	echo "Invalid command. Run './boiler_favorites.sh help' to see the documented usage."
fi

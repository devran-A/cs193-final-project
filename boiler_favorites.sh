#!/bin/bash

#adds all arguments passed to add_args to the first argument, which is the file name
#creates the .config directory for boiler favorites and the passed file name if it doesn't already exist
add_args() {
        local file_name=$1
	shift 1

        if [ ! -d ~/.config/bf/ ]; then
                mkdir -p ~/.config/bf/
        fi

        if [ ! -f ~/.config/bf/$file_name ]; then
                touch ~/.config/bf/$file_name
        fi

        for arg in "$@"; do
                echo $arg >> ~/.config/bf/$file_name
        done
}
#creates the config directory for boiler favorites if it doesn't exist, as well as the passed file name
init_file() {
	if [ ! -d ~/.config/bf/ ]; then
                mkdir -p ~/.config/bf/
        fi

        if [ ! -f ~/.config/bf/$1 ]; then
                touch ~/.config/bf/$1
        fi
}

#creates conf.txt inside config if it does't exist, and initializes its variables
init_config() {
	if [ ! -d ~/.config/bf/ ]; then
		mkdir -p ~/.config/bf/
	fi
	
	if [ ! -f ~/.config/bf/conf.txt ]; then
		touch ~/.config/bf/conf.txt
		echo "RUN_ON_BOOT=0" >> ~/.config/bf/conf.txt 
		echo "LAST_RUN=MM-DD-YYYY" >> ~/.config/bf/conf.txt
	fi
}

#check if it's possible to connect to purdue's dining api, if so, retrieve the menu for the specified date and location using curl
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

#checks if the passed arguments already exist in preferred_locations.txt, and makes sure that they are a valid location
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

#self explanatory, checks if favorite_foods.txt or preferred_locations.txt is empty, exits if either one is empty
check_empty() {
        if [[ ! -s ~/.config/bf/favorite_foods.txt || ! -s ~/.config/bf/preferred_locations.txt ]]; then
                echo "Favorite food and or preferred location list is empty! Use 'bf add {food|location} <item>...' in order to use this command."
        exit 1
        fi
}

#remove the passed arguments from the file passed
remove_args() {
	local file_name=$1
	
	shift 1

	for arg in "$@"; do
		number=$(grep -nx "$arg" ~/.config/bf/$file_name) #fetches the line number containing the current item being read from $file_name
		if [ ! "$?" -eq 0 ]; then
			echo "'$arg' not found!"
			exit 1
		else
			number=$(echo $number | sed 's/:.*//') #remove the :PHRASE that grep adds at the end of the number indicating the line
       			sed -i "${number}d" ~/.config/bf/$file_name #delete the line according to what $number is at the specified file			
		fi
	done

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
                echo "Usage: bf add {food|location} <item>..."
        fi
elif [ "$1" = "view" ]; then
	if [ "$2" = "foods" ] && [ "$#" -eq 2 ]; then
		init_file favorite_foods.txt
		cat ~/.config/bf/favorite_foods.txt
	elif [ "$2" = "locations" ] && [ "$#" -eq 2 ]; then
		init_file preferred_locations.txt
		cat ~/.config/bf/preferred_locations.txt
	else
		echo "Usage: bf view {foods|locations}"
	fi
elif [ "$1" = "remove" ]; then
	if [ "$2" = "food" ] && [ "$#" -gt 2 ]; then
		init_file favorite_foods.txt
		shift 2
		remove_args favorite_foods.txt "$@"
	elif [ "$2" = "location" ] && [ "$#" -gt 2 ]; then
		init_file preferred_locations.txt
		shift 2
		remove_args preferred_locations.txt "$@"
	else
		echo "Usage: bf remove {food|location} <item>..."
	fi
elif [ "$1" = "help" ] && [ "$#" -eq 1 ]; then
	echo "Acceptable dining courts to add to the preferred list are: {Hillenbrand|Windsor|Earhart|Wiley|Ford}"
	echo "bf add food <item>... #add food items to favorite_foods.txt"
	echo "bf add location <location>... #add dining locations to preferred_locations.txt"
	echo "bf remove food <item>... #remove food items from favorite_foods.txt"
	echo "bf remove location <item>... #remove location from preferred_locations.txt"
	echo "bf view foods #prints favorite_foods.txt's contents"
	echo "bf view locations #prints preferred_locations.txt's contents"
	echo "bf #scrapes purdue's dining website and checks if specified favorite foods are located at the specified dining courts"
	echo "bf run-on-boot {enable|disable} #toggles run on boot functionality"
	echo "NOTE: WHEN YOU'RE RUNNING A COMMAND THAT TAKES ITEMS, WRAP EACH ITEM IN A STRING, OTHERWISE SPACES IN THE ITEM WILL SEPERATE THE ITEM INTO DIFFERENT PARTS"
elif [ "$1" = "run-on-boot" ]; then
	today=$(date +%m-%d-%Y)
	if [ "$2" = "enable" ] && [ "$#" -eq 2 ]; then
		init_config
		sed -i 's/RUN_ON_BOOT=0/RUN_ON_BOOT=1/' ~/.config/bf/conf.txt
	elif [ "$2" = "disable" ] && [ "$#" -eq 2 ]; then
		init_config
		sed -i 's/RUN_ON_BOOT=1/RUN_ON_BOOT=0/' ~/.config/bf/conf.txt
	else
		echo "Usage: bf run-on-boot {enable|disable}"

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
			format=$(echo $json | jq --arg item_name "$item" -r '.Meals[] |.Name as $meal | .Stations[] | .Name as $station | .Items[] | .Name as $food | select(.Name | ascii_downcase | contains($item_name | ascii_downcase)) | "\($food) | \($meal) | \($station)\n"') #Parses the json from curl, saving matches that contain the food item string from favorite_foods.txt, as well as the station and meal time that item is available at, does this for as many different meal times there are
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
	echo "Invalid command. Run 'bf help' to see the documented usage."
fi

# Boiler Favorites

A bash script that displays if your favorite foods are available at Purdue Dining courts.

## The Problem

Purdue's dining website allows you to see ahead of time what options are given at the dining courts, but it's often tedious to click through each dining court just to find what you're looking for.

## How It Works

Scrapes Purdue's dining website to retrieve menu options, then checks if the user's favorite foods are available at their preferred dining courts. If so, the dining court, which station, and which meal time their favorite food is offered atis printed to the terminal.

![System diagram](system-diagram.png)

## Tech Stack

- **Language:** Bash
- **External tools:** curl, jq, cat, date, touch, echo, grep, sed, mkdir, read, command, ping, chmod, and dining court API

## Setup

```bash
#This script has only been tested on Ubuntu, but it should work for other linux distributions
git clone https://github.com/devran-A/cs193-final-project
cd cs193-final-project
chmod +x install.sh
./install.sh #If you're prompted to install 'jq' then do so with your package manager and rerun the install script
#Feel free to delete the repo after the install script was successful
```

## Usage

Acceptable dining courts to add to the preferred list are Wiley, Winsdor, Ford, Hillenbrand, and Earhart, each typed exactly as shown.

```bash
bf add food <item>... #add food items to favorite_foods.txt
bf add location <location>... #add dining locations to preferred_locations.txt
bf view foods #prints favorite_foods.txt's contents
bf view locations #prints preferred_locations.txt's contents
bf #scrapes purdue's dining website and checks if specified favorite foods are located at the specified dining courts
bf run-on-boot {enable|disable} #toggles run on boot functionality
```

**NOTE: WHEN YOU'RE RUNNING A COMMAND THAT TAKES ITEMS, WRAP EACH ITEM IN A STRING, OTHERWISE SPACES IN THE ITEM WILL SEPERATE THE ITEM INTO DIFFERENT PARTS**

```bash
bf add food Cheese Pizza Burger #this will create three food entries, don't do this!
bf ad food "Cheese Pizza" "Burger" #this will create two food entries, do this instead!
```

## Roadmap

- [x] Terminal notifications whenever user boots their system
- [ ] Filter for allergens
- [ ] Alternative suggestions/locations

## Author

Devran Aydin, [My GitHub](https://github.com/devran-A/)

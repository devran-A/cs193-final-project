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

        for arg in $@; do
                echo $arg >> ~/.config/bf/$file_name
        done
}

if [ "$1" = "add" ]; then
        if [ "$2" = "food" ] && [ "$#" -gt 2 ]; then
                shift 2
                add_args favorite_foods.txt $@
                exit 1
        elif [ "$2" = "location" ] && [ "$#" -gt 2 ]; then
                shift 2
                add_args preferred_locations.txt $@
                exit 1
        else
                echo "Usage: ./boiler_favorites add {food|location} <item>..."
                exit 1
        fi
fi

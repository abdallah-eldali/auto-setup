#!/bin/bash

#Display the workspace layout
while :; do
	echo $(swaymsg -t get_workspaces | jq -r ".[] | select(.output==\"$1\" and .visible==true) | .representation")
	sleep 0.25
done

exit 0

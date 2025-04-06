#!/bin/bash

# Count notifications in the notification history
count=$(swaync-client -c)
if [ "$count" -gt 0 ]; then
    echo "󰂛 $count"
else
    echo "󰂚"
fi 
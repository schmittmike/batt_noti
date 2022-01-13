#!/bin/sh 

first_warning=40
second_warning=10
third_warning=5
charge_reset=25

initial=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o '[0-9]\+%' | tr -d '%')

if [[ $initial -lt $first_warning+1 ]]; then
    flag=1
    if [[ $initial -lt $second_warning+1 ]]; then
        flag=2
        if [[ $initial -lt $third_warning+1 ]]; then
            flag=3
        fi
    fi
else
    flag=0
fi


#echo "initial: $initial"

while :
do
    PERCENT=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o '[0-9]\+%' | tr -d '%')

    #echo "percent: $PERCENT%"
    #echo "flag: $flag"

    if [[ $flag -eq 0 ]]; then
        if [[ $PERCENT -lt $first_warning+1 ]]; then
            echo "under $first_warning%"
            notify-send -u normal -t 15000 " $first_warning% battery"
            flag=1    
        fi
    elif [[ $flag -eq 1 ]]; then
        if [[ $PERCENT -lt $second_warning+1 ]]; then
            echo "under $second_warning%"
            notify-send -u critical -t 15000 " $second_warning% battery"
            flag=2
        fi
    elif [[ $flag -eq 2 ]]; then
        if [[ $PERCENT -lt $third_warning+1 ]]; then
            echo "under $third_warning%"
            notify-send -u critical -t 15000 " $third_warning% battery"
            flag=4
        fi
    elif [[ $flag -eq 3 ]]; then
        echo "under $third_warning%"
        notify-send -u critical -t 15000 " $third_warning% battery"
        flag=4
    else
        if [[ $PERCENT -gt $charge_reset ]]; then
            echo "sufficienty charged past charge reset threshold ($charge_reset%)"
            flag=0
        fi
    fi

sleep 60
done

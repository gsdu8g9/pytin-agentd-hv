#!/usr/bin/env bash

inc=5
while (( inc > 0 )); do
    date
    sleep 1
    inc=$((inc-1))
done

exit 0

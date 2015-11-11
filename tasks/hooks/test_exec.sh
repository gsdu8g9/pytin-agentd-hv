#!/usr/bin/env bash

echo "Passed $1"

python optconv.py $1 config.shell

cat config.shell

inc=5
while (( inc > 0 )); do
    date
    sleep 1
    inc=$((inc-1))
done

exit 0

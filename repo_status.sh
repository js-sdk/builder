#!/bin/sh

if [ ! -z "`git status -s`" ]; then
    echo "Working tree is not clean"
    git status -s
    read -p "Proceed? [Y/n] " PROCEED_OK

    if [[ "$PROCEED_OK" -ne "Y" || "$PROCEED_OK" -ne "y" ]]; then
        echo "Stopping publish"
        exit 1
    fi
fi

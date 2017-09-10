#!/bin/sh

JQ=$(which jq)

# temporary file with current and next versions.
VERSION=./builder/.version

# temporary package.json file
NPJSON=./builder/up.json

# the package.json file.
PJSON="package.json"

CURRENT_BRANCH=`git branch | grep '^*' | awk '{ print $2 }'`

if [[ "$CURRENT_BRANCH" != "master" ]]; then
    echo "Bail out. Current branch is not master."
    echo "Curent branch: `git branch | grep '^*' | awk '{ print $2 }'`"
    exit 1;
fi

case $1 in
    --update)
        if [[ -z "$JQ" ]]; then
            echo "jq is missing."
        fi

        CURRENT_VERSION=`$JQ ".version" $PJSON | cut -d\" -f2`

        echo "Current version: $CURRENT_VERSION"
        read -p "New version: " NEW_VERSION

        if [[ ! -z "$(git tag -l | grep ${NEW_VERSION})" ]]; then
            echo "Tag $NEW_VERSION already exists."
            exit 1
        fi

        echo "$CURRENT_VERSION $NEW_VERSION" > $VERSION
        ;;
    --commit)
        CURRENT_VERSION=`awk '{ print $1 }' $VERSION`
        NEW_VERSION=`awk '{ print $2 }' $VERSION`

        $JQ ".version = \"${NEW_VERSION}\"" $PJSON > $NPJSON
        cat $NPJSON > $PJSON
        ;;
    --clean)
        rm $VERSION $NPJSON
        ;;
    *)
        echo "usage:"
        echo "   --update - to set the next version."
        echo "   --commit - write to all necessary files."
        echo "   --clean  - remove all temporary files."
        exit 1;
        ;;
esac

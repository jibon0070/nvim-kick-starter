#!/bin/bash

if ! [ $(command -v git | wc -l) -eq 1 ]; then
	notify-send "Auto sync failed" "Please install git" -u "critical"
	exit 1
fi

git checkout main

git pull

cp ~/.config/nvim ./config -R

if [ $(git status | grep -E "^nothing\s" | wc -l) -ne 1 ]; then
	git add -A
	git commit -m "Update config $(date '+%Y-%m-%d')"
	if git push; then
		notify-send "Auto sync done"
	else
		notify-send "Auto sync failed" "Please fix the error first" -u "critical"
	fi
fi

exit 0

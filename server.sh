#!/usr/bin/env bash
if [[ -f server/main.lua ]]; then
	love server
else
	echo "main.lua not found. are you in the wrong folder?"
fi
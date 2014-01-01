#!/usr/bin/env bash
if [[ -f client/main.lua ]]; then
	love client
else
	echo "main.lua not found. are you in the wrong folder?"
fi
#!/bin/bash
dow=$(date);
echo $(ls -l)
filename="$(echo -e "${dow}" | tr -d '[:space:]')"
touch ${filename}.txt

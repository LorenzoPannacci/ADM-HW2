#!/bin/bash

# dataset location
input='datasets/series.json'

# regex to extract id and title of the series
pattern1='"id": "([0-9]+)", "title": "(.+)", "description":'

# regex to extract the substring about the works of the series
pattern2='"works": \[\{(.+)\}\]'

# regex to extract the "book_counts" fields from the works substring.
pattern3='"books_count": "([0-9]+)"'

# regex to extract info from the string that represent a series
pattern4='(.+)\|(.+)\|(.+)'

series_list=()
while read -r line # cycle trough each line
do
	if [[ $line =~ $pattern1 ]]; then # get series title and is
		id="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[2]}"
	fi

	if [[ $line =~ $pattern2 ]]; then # get series total works count
        works_string="${BASH_REMATCH[1]}"
        
        works_count=0
		while [[ $works_string =~ $pattern3 ]]; do
			value="${BASH_REMATCH[1]}"
			((works_count += value))
			works_string="${works_string/${BASH_REMATCH[0]}/}"
		done
	fi
	
	new_series="$works_count""|""$title""|""$id" # create list item
	series_list+=("$new_series") # append new item to list

done < "$input"

# order list only by the first field of the string, the works_count
ordered_string=$(printf "%s\n" "${series_list[@]}" | sort -t'|' -k 1,1n | tac)

# the sort made it a string so convert it back to list
IFS=$'\n'
ordered_list=($(echo "$ordered_string"))
IFS=' '

# print the informations requested
echo "id	title	total_books_count"
for ((i=0; i<5; i++)); do
	elem="${ordered_list[i]}"
	if [[ $elem =~ $pattern4 ]]; then
        echo "${BASH_REMATCH[3]} ${BASH_REMATCH[2]} ${BASH_REMATCH[1]}"
	fi
done

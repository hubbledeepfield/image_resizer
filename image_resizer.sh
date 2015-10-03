#!/bin/bash

set -ue

[ $# -ge 1 ] || { echo "Usage $0 <directory> <max_size>"; exit 1; }

#1. Resize each picture in a given directory.
#2. Rename each picture with "$directory_name + $counter".
#3. Several scale options.
#4. Separate vertical and horizontal pictures.
#5. Store resized files in a new directory called like "$directory_name + resized".
#6. Progress bar.
#7. Info messages.

sips=/usr/bin/sips

orig_dir="$1"
default_size="1024"
max_size=${2:-$default_size}

total_files=$(ls ${orig_dir} | wc -l)

[ $total_files -eq 0 ] && { echo "The folder you've specified is empty. Terminating the script"; exit 1; }

res_dir_name=$( (basename "${orig_dir}"_resized | sed -E "s/[[:space:]]+/_/g" ) )
res_dir=$HOME/$res_dir_name

function resize {
mkdir $res_dir
    ind=1
    find ${orig_dir} -type f -print0 | \
        (while read -d $'\0' i; do cp "$i" ${res_dir}/${ind}.jpg
        $sips --resampleWidth ${max_size} --setProperty formatOptions best ${res_dir}/${ind}.jpg > /dev/null 2>&1
        progr=$(echo "scale=0; 100*${ind}/${total_files}" | bc -l )
        echo "progress: ${progr}% "
        ind=$((${ind} + 1))
        done)
    echo "Completed. Bye! "
}

echo "Resized pictures will be stored to: ${res_dir}"

if [ -d ${res_dir} ]; then
    existing_modified=$( (stat -f "%t%Sm" $res_dir | sed -E "s/[[:space:]]+/ /g") )
    existing_contains=$( (ls $res_dir | wc -l | sed -E "s/[[:space:]]+/ /g") )
    echo "$res_dir already exists. It was modified on$existing_modified and contains$existing_contains files" ;
    echo "Are you sure you want to continue?"
    echo "y / n"
    read choice
    if [ "$choice" == "y" ]; then
        rm -rf $res_dir
        resize
    elif [ "$choice" == "n" ]; then
        echo "OK. Bye!"
    else
        echo "Go home, you're drunk"
    fi
else
    resize
fi
exit

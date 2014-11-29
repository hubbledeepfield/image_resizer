#!/bin/bash

set -ue

[ $# -eq 1 ] || { echo "Usage $0 <directory>"; exit 1; }

#1. Resize each picture in a given directory.
#2. Rename each picture with "$directory_name + $counter".
#3. Several scale options.
#4. Separate vertical and horizontal pictures.
#5. Store resized files in a new directory called like "$directory_name + resized".
#6. Progress bar.
#7. Info messages.

sips=/usr/bin/sips
orig_dir="$1"
res_dir=$( (basename "${orig_dir}"_resized | sed -E "s/[[:space:]]+/_/g" ) )

echo ${res_dir}

[ -d ${res_dir} ] || mkdir ${res_dir}

ind=1

total_files=$(ls -ltr ${orig_dir} | wc -l)

find ${orig_dir} -type f -print0 | \
    (while read -d $'\0' i; do cp "$i" ${res_dir}/${res_dir}_${ind}.jpg
     $sips -Z 1024 ${res_dir}/${res_dir}_${ind}.jpg > /dev/null 2>&1
     progr=$(echo "scale=0; 100*${ind}/${total_files}" | bc -l )
     echo "progress: ${progr}% "
     ind=$((${ind} + 1))
    done)

echo "Completed"

exit

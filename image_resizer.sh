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

ind=0

find ${orig_dir} -type f -print0 | \
    (while read -d $'\0' i; do cp "$i" ${res_dir}/${res_dir}_${ind}.jpg
    picture_width=$( ${sips} -g "pixelWidth" ${res_dir}/${res_dir}_${ind}.jpg | awk -F": " '{print $2}' | sed '/^\s*$/d' )
    picture_height=$( ${sips} -g "pixelHeight" ${res_dir}/${res_dir}_${ind}.jpg | awk -F": " '{print $2}' | sed '/^\s*$/d' )
        if [ ${picture_width} -ge ${picture_height} ]; then
            $sips -Z 1024 ${res_dir}/${res_dir}_${ind}.jpg > /dev/null 2>&1
        else
            $sips -Z 768 ${res_dir}/${res_dir}_${ind}.jpg > /dev/null 2>&1
        fi
        ind=$((${ind} + 1))
    done)

echo "done"

exit

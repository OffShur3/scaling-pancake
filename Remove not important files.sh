#!/bin/bash

patterns=('allPorts')

printf "\e[1;34mBorrare los archivos temporales \e[0m\n"
echo "↓ Permiteme plis... :)"
dir=/mnt/UwU/Mah4_Kal1/scaling-pancake
cd "$dir"

temp_file=$(mktemp)
find -type f > "$temp_file"


echo "Archivos eliminados:"
printf "\e[3;31m"

count=0
for pattern in "${patterns[@]}"; do
  grep -F "$pattern" "$temp_file" | while read -r matched_file; do
    file=$(echo "$matched_file" | cut -d "/" -f 2)
    echo "$dir/$file"
    # rm -f "$dir/$file"
    count=$((count + 1))
  done
done
rm "$temp_file"

printf "\e[0m"
echo "Total de archivos eliminados: $count"
cd - > /dev/null


#!/bin/bash


FILES_TO_MONITOR=("TEST_FIM_IN_HOUSE" "MMMMMMTEST.TXT")  #Put your files Here


HASH_FILE="FILE_FIM_HASHES_SAVE.txt"

generate_initial_hashes() {
    echo "calculate first hashes"
    for file in "${FILES_TO_MONITOR[@]}"; do
         if [ -f "$file" ]; then 
                 sha256sum "$file" >> "$HASH_FILE"
         else
                 echo "$file file not found" 
         fi
     done 
     echo "we save first hash value $HASH_FILE"
}                 
    

check_file_integrity() {
   echo "check integrity of files"
   while IFS= read -r line; do
      stored_hash=$(echo $line | awk '{print $1}')
      file=$(echo $line | awk '{print $2}')
      
      
      if [ -f "$file" ]; then
            current_hash=$(sha256sum "$file" | awk '{print $1}')
            if [ "$stored_hash" != "$current_hash" ]; then
                echo "warning $file file is changed YA m3lem...!"
            else 
                echo "$file file is good el good ya bro"
            fi
      else
            echo "$file file not found yasta" 
      fi
   done < "$HASH_FILE"
}

if [ ! -f "$HASH_FILE" ]; then
     generate_initial_hashes
else
     check_file_integrity
fi                                
   

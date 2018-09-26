#!/bin/bash

zip_file=/data/backups/www/`date +"%Y-%m-%d_%H-%M-%S"`.zip
zip -r1 --quiet $zip_file /var/www -x "*.mp4" -x "*.webm" -x "*.ogv" -x "*.log" -x "*/.git/*" -x "*.mov" -x "*.wmv" -x "*/logs/*" -x "*/wfcache/*" -x "*/vendi_cache/*" -x "*/vendor/*" -x "*/node_modules/*"

# Create 64 bytes of random data, asymetrically encrypt that with ssh public key write that two *.enc.key
# Then use that key to symetrically encrypt the file to *.enc
openssl rand 64 | tee >(openssl enc -aes-256-cbc -pass stdin -in $zip_file -out $zip_file.enc) | openssl rsautl -encrypt -pubin -inkey /vbin/ENCRYPTION_KEY_HERE -out $zip_file.enc.key

sudo vendi-do-backup backup --private-key=PRIVATE_KEY_HERE --public-key=PUBLIC_KEY_HERE --bucket=vendi-backup --file=$zip_file.enc     --name=BACKUP_NAME_HERE_www_back
sudo vendi-do-backup backup --private-key=PRIVATE_KEY_HERE --public-key=PUBLIC_KEY_HERE --bucket=vendi-backup --file=$zip_file.enc.key --name=BACKUP_NAME_HERE_www_back_key


#Delete our temporary file
rm $zip_file

#Prune files older than 5 days
find /data/backups/www/ -mtime +5 -print0 | xargs -0 -r rm

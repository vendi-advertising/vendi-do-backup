#!/bin/bash

# Back file name
gz_file=/data/backups/mysql/$(date +"%Y-%m-%d_%H-%M-%S").sql.gz

# Dump to disk
mysqldump -uvendibackup -h localhost --all-databases | gzip --best > "$gz_file"

# Create 64 bytes of random data, asymetrically encrypt that with ssh public key write that two *.enc.key
# Then use that key to symetrically encrypt the file to *.enc
openssl rand 64 | tee >(openssl enc -aes-256-cbc -pass stdin -md sha512 -pbkdf2 -iter 1000 -in "$gz_file" -out "$gz_file.enc") | openssl rsautl -encrypt -pubin -inkey /vbin/ENCRYPTION_KEY_HERE -out "$gz_file.enc.key"

sudo vendi-do-backup backup --private-key=PRIVATE_KEY_HERE --public-key=PUBLIC_KEY_HERE --bucket=vendi-backup --file="$gz_file.enc"     --name=BACKUP_NAME_HERE_db_back
sudo vendi-do-backup backup --private-key=PRIVATE_KEY_HERE --public-key=PUBLIC_KEY_HERE --bucket=vendi-backup --file="$gz_file.enc.key" --name=BACKUP_NAME_HERE_db_back_key

#Delete our temporary file
rm "$gz_file"

#Prune files older than 5 days
find /data/backups/mysql/ -mtime +5 -print0 | xargs -0 -r rm

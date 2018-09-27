#!/bin/bash

archive_file=/data/backups/www/`date +"%Y-%m-%d_%H-%M-%S"`.tar.gz
tar zcvf $archive_file                      \
    --exclude="*/logs/*"                    \
    --exclude="*/node_modules/*"            \
    --exclude="*/vendor/*"                  \
    --exclude="*/wp-security-audit-log/*"   \
    --exclude="*/wfcache/*"                 \
    --exclude="*/vendi_cache/*"             \
    --exclude="*/.git/*"                    \
     /var/www/

# Create 64 bytes of random data, asymetrically encrypt that with ssh public key write that two *.enc.key
# Then use that key to symetrically encrypt the file to *.enc
openssl rand 64 | tee >(openssl enc -aes-256-cbc -pass stdin -in $archive_file -out $archive_file.enc) | openssl rsautl -encrypt -pubin -inkey /vbin/ENCRYPTION_KEY_HERE -out $archive_file.enc.key

sudo vendi-do-backup backup --private-key=PRIVATE_KEY_HERE --public-key=PUBLIC_KEY_HERE --bucket=vendi-backup --file=$archive_file.enc     --name=BACKUP_NAME_HERE_www_back
sudo vendi-do-backup backup --private-key=PRIVATE_KEY_HERE --public-key=PUBLIC_KEY_HERE --bucket=vendi-backup --file=$archive_file.enc.key --name=BACKUP_NAME_HERE_www_back_key


#Delete our temporary file
rm $archive_file

#Prune files older than 5 days
find /data/backups/www/ -mtime +5 -print0 | xargs -0 -r rm

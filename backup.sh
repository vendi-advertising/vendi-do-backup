#!/bin/bash

# Vendi standard backup script as of 2019-08-09.
# Logic for retention from https://github.com/todiadiyatmo/bash-backup-rotation-script

############################################################
#1 - Set this to the root where backups are generally kept #
############################################################
BACKUP_FOLDER_SHARED_ROOT_WITH_TRAILING_SLASH=/data/backups/

#################################################################
#    Set this to a short description of the client and/or site. #
#2 - This will be used as the filename prefix so it should      #
#    follow file-system safety rules for names.                 #
#################################################################
BACKUP_DESCRIPTIVE_NAME=BACKUP_NAME_HERE

########################################################
#3 - Set this to the abs path of the folder to back up #
########################################################
ABS_PATH_TO_FOLDER_TO_BACKUP=/var/www/

################################################################
#4 - Encryption keys. If you don't know what to do, see Chris. #
################################################################
PUBLIC_KEY=PUBLIC_KEY_HERE
PRIVATE_KEY=PRIVATE_KEY_HERE
ENCRYPTION_KEY_ABS_PATH=ENCRYPTION_KEY_HERE

#######################
#5 - Change as needed #
#######################
BACKUP_DAILY=true
BACKUP_WEEKLY=true
BACKUP_MONTHLY=true

BACKUP_RETENTION_DAILY=14
BACKUP_RETENTION_WEEKLY=3
BACKUP_RETENTION_MONTHLY=3

###################################################################
#    Set this to either www or db                                 #
#6 - NOTE: This should be provided as the first parameter to this #
#    script however it can also be manually set if needed.
###################################################################
BACKUP_TYPE=$1





      ####################
    ########################
  ############################
################################
## DO NOT EDIT ANYTHING BELOW ##
################################
  ############################
    ########################
      ####################

#Get the month and day of weeks as numbers
MONTH=`date +%d`
DAYWEEK=`date +%u`

#Fix problems with octal numbers by removing leading zero
#See https://stackoverflow.com/a/12821845/231316
MONTH=${MONTH#0}
DAYWEEK=${DAYWEEK#0}

if [[ ( $MONTH -eq 1 ) && ( $BACKUP_MONTHLY == true ) ]];
        then
        FN='monthly'
elif [[ ( $DAYWEEK -eq 7 ) && ( $BACKUP_WEEKLY == true ) ]];
        then
        FN='weekly'
elif [[ ( $DAYWEEK -lt 7 ) && ( $BACKUP_DAILY == true ) ]];
        then
        FN='daily'
fi

if [[ ( $BACKUP_TYPE == "www" ) ]];
    then
    BACKUP_EXTENSION=.tar.gz
elif [[ ( $BACKUP_TYPE == "db" ) ]];
    then
    BACKUP_EXTENSION=.sql.gz
else
    echo "Invalid backup type: ${BACKUP_TYPE}"
    exit 1
fi

# The data/timestamp for the file
DATE=`date +"%Y-%m-%d_%H-%M-%S"`

# The absolute path to the backup folder
BACKUP_DIR=${BACKUP_FOLDER_SHARED_ROOT_WITH_TRAILING_SLASH}${BACKUP_TYPE}

# The absolute path to various files created
ARCHIVE_FILE=${BACKUP_DIR}/${BACKUP_DESCRIPTIVE_NAME}-${FN}-${DATE}${BACKUP_EXTENSION}
ARCHIVE_FILE_ENCRYPTED=${ARCHIVE_FILE}.enc
ARCHIVE_FILE_ENCRYPTION_KEY=${ARCHIVE_FILE}.enc.key

#Remove the leading trailing slash to fix a tar warning
ABS_PATH_TO_FOLDER_TO_BACKUP=$(sed 's|^/||' <<< $ABS_PATH_TO_FOLDER_TO_BACKUP)

function create_local_archive_db
{
    mysqldump -uvendibackup -h localhost --all-databases | gzip --best > $ARCHIVE_FILE
}

function create_local_archive_www
{
    # Probably not needed
    cd /

    # The actual backup with common exclusions
    tar zcf $ARCHIVE_FILE                       \
        --exclude="*/logs/*"                    \
        --exclude="*/node_modules/*"            \
        --exclude="*/vendor/*"                  \
        --exclude="*/wp-security-audit-log/*"   \
        --exclude="*/wfcache/*"                 \
        --exclude="*/vendi_cache/*"             \
        --exclude="*/.git/*"                    \
        -C /                                    \
        ${ABS_PATH_TO_FOLDER_TO_BACKUP}
}

function create_local_archive_all
{
    # Sanity check that the root backup folder exists
    mkdir --parents ${BACKUP_DIR}

    if [[ ( $BACKUP_TYPE == "www" ) ]];
        then
        create_local_archive_www
    elif [[ ( $BACKUP_TYPE == "db" ) ]];
        then
        create_local_archive_db
    fi
}

function encrypt_archive_file
{
    # Create 64 bytes of random data, asymetrically encrypt that with ssh public key write that to *.enc.key
    # Then use that key to symetrically encrypt the file to *.enc
    openssl rand 64 | tee >(openssl enc -aes-256-cbc -pass stdin -md sha512 -pbkdf2 -iter 1000 -in ${ARCHIVE_FILE} -out ${ARCHIVE_FILE_ENCRYPTED}) | openssl rsautl -encrypt -pubin -inkey ${ENCRYPTION_KEY_ABS_PATH} -out ${ARCHIVE_FILE_ENCRYPTION_KEY}
}

function copy_local_archive_to_do
{
    sudo vendi-do-backup backup                 \
        --private-key=${PRIVATE_KEY}            \
        --public-key=${PUBLIC_KEY}              \
        --bucket=vendi-backup                   \
        --file=${ARCHIVE_FILE_ENCRYPTED}        \
        --name=${BACKUP_DESCRIPTIVE_NAME}_${BACKUP_TYPE}_back

    sudo vendi-do-backup backup                 \
        --private-key=${PRIVATE_KEY}            \
        --public-key=${PUBLIC_KEY}              \
        --bucket=vendi-backup                   \
        --file=${ARCHIVE_FILE_ENCRYPTION_KEY}   \
        --name=${BACKUP_DESCRIPTIVE_NAME}_${BACKUP_TYPE}_back_key
}

function cleanup_local
{
    #Delete our temporary file
    rm ${ARCHIVE_FILE}
}

function prune_local
{
    #Prune files older than 5 days
    #find /data/backups/www/ -mtime +5 -print0 | xargs -0 -r rm

    cd $BACKUP_DIR
    ls -t | grep $BACKUP_DESCRIPTIVE_NAME | grep daily   | sed -e 1,"$BACKUP_RETENTION_DAILY"d   | xargs -d '\n' rm -R > /dev/null 2>&1
    ls -t | grep $BACKUP_DESCRIPTIVE_NAME | grep weekly  | sed -e 1,"$BACKUP_RETENTION_WEEKLY"d  | xargs -d '\n' rm -R > /dev/null 2>&1
    ls -t | grep $BACKUP_DESCRIPTIVE_NAME | grep monthly | sed -e 1,"$BACKUP_RETENTION_MONTHLY"d | xargs -d '\n' rm -R > /dev/null 2>&1
}

function run_it_all
{
    create_local_archive_all
    encrypt_archive_file
    copy_local_archive_to_do
    cleanup_local
    prune_local
}


if [[ ( $BACKUP_DAILY == true ) && ( ! -z "$BACKUP_RETENTION_DAILY" ) && ( $BACKUP_RETENTION_DAILY -ne 0 ) && ( $FN == daily ) ]]; then
    run_it_all
fi
if [[ ( $BACKUP_WEEKLY == true ) && ( ! -z "$BACKUP_RETENTION_WEEKLY" ) && ( $BACKUP_RETENTION_WEEKLY -ne 0 ) && ( $FN == weekly ) ]]; then
    run_it_all
fi
if [[ ( $BACKUP_MONTHLY == true ) && ( ! -z "$BACKUP_RETENTION_MONTHLY" ) && ( $BACKUP_RETENTION_MONTHLY -ne 0 ) && ( $FN == monthly ) ]]; then
    run_it_all
fi

#!/bin/bash

#This directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#The directory to build to
BUILD_DIR="$DIR/tmp"

#Find our PHP executable
PHP=`which php`

BUILD_FILE="$BUILD_DIR/releases/vendi-do-backup.phar"

BUILD_FILE_FINAL="$DIR/releases/vendi-do-backup.phar"

#Erase the build directory if it exists already
if [ -d $BUILD_DIR ]; then
    echo 'Removing temp directory'
    rm -r $BUILD_DIR
    mkdir $BUILD_DIR
fi

if [ -f $BUILD_FILE_FINAL ]; then
    echo 'Removing previous build file'
    rm $BUILD_FILE_FINAL
fi

#Clone our repo
git clone git@github.com:vendi-advertising/vendi-do-backup.git $BUILD_DIR

#Enter the directory
cd $BUILD_DIR

#Update composer, don't include dev items
composer update --no-dev

$PHP --file "$BUILD_DIR/build-phar.php"

mv $BUILD_FILE $BUILD_FILE_FINAL

chmod +x $BUILD_FILE_FINAL

cd ..

rm -rf $BUILD_DIR

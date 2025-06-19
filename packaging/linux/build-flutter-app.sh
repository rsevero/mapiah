#!/bin/bash


# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x


projectName=Mapiah

archiveName=${projectName}-Linux-Portable.tar.gz
baseDir=$(pwd)


# ----------------------------- Build Flutter app ---------------------------- #


flutter pub get
flutter build linux --release

cd build/linux/x64/release/bundle || exit
tar -czaf $archiveName ./*
mv $archiveName "$baseDir"/
cd "$baseDir"
sha256sum $archiveName

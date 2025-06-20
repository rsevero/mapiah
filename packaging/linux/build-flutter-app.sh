#!/bin/bash


# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x


projectName=mapiah

archiveName=${projectName}-Linux-Portable.tar.gz
baseDir=$(pwd)


# ----------------------------- Build Flutter app ---------------------------- #


flutter pub get
flutter build linux --release

cd build/linux/x64/release/bundle || exit
rm -f "$archiveName"
tar -czaf "$archiveName" ./*
mv "$archiveName" "$baseDir"/
cd "$baseDir"

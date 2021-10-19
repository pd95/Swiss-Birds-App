#!/bin/sh

# Make sure we halt on errors and output all the commands
set -ex

rm -rf website
mkdir -p website/de
mkdir -p website/en

# For each language we need, convert the framed image to jpeg and rename it
for f in de/*_framed.png en/*_framed.png ; do 
    newName="${f//_framed/}"
    newName=${newName//"iPad Pro (12.9-inch) (4th generation)-"/iPad_}
    newName=${newName//"iPhone Xs-"/iPhone_}
    newName=${newName//".png"/.jpeg}
    sips -s format jpeg -o "website/$newName" "$f"
done   
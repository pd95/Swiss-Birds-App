#!/bin/sh

# Create required directories
mkdir -p data/species voices images/headshots images/artbilder svg/download

# Fetching main JSON data
for r in list labels filternames ; do
    for l in de fr it en ; do
        echo Fetching vds-$r-$l.json
        curl -#fo data/vds-$r-$l.json https://www.vogelwarte.ch/elements/snippets/vds/static/assets/data/vds-$r-$l.json
    done
done

# post-process the data files
node process_vds_data.js

# Prepare script to fetch species data
TMP_SCRIPT=fetch_bird_data.sh
echo "Generating script to fetch pictures and sounds: $TMP_SCRIPT"
cat > "$TMP_SCRIPT" <<EOM 
#!/usr/bin/env sh
# This file is generated by $0! Do not edit as everything will be overwritten.

set -x
EOM

# Use node script to generate script
node gen_curl.js >> "$TMP_SCRIPT"

# execute generated script and remove it
chmod u+x $TMP_SCRIPT
"./$TMP_SCRIPT" && rm "$TMP_SCRIPT"

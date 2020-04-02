#!/bin/sh

set -e
# set -x 

COPY_ASSETS=true
COPY_BIRD_DATA=true
COPY_DATA=true

mkdir -p Birds.xcassets
cd Birds.xcassets

if [ "x$COPY_ASSETS" == xtrue ]; then
  mkdir -p assets
  cd assets

  # Copy MP3 bird voices
  echo "Copying bird mp3 files..."
  cp -rcp ../../voices/*.mp3 .
  for f in *.mp3 ; do 
      d="$f.dataset"
      echo "$f > $d"
      mkdir -p "$d"
      mv "$f" "$d"

      cat > "$d/Contents.json" <<EOM 
{
  "info" : {
    "version" : 1,
    "author" : "script"
  },
  "data" : [
    {
      "idiom" : "universal",
      "filename" : "$f"
    }
  ]
}
EOM
  done

  # Copy bird pictures
  echo "Copying bird picture files..."
  cp -rcp ../../images/artbilder/*.jpg .
  for f in *.jpg ; do 
      d="$f.imageset"
      echo "$f > $d"
      mkdir -p  "$d"
      mv "$f" "$d"

      cat > "$d/Contents.json" <<EOM 
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "$f",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "script"
  }
}
EOM
  done

  # Copy bird thumbnails
  cp -rcp ../../images/headshots/*.jpg .
  for fh in *.jpg ; do
      f=`echo "$fh" | sed -E 's/([0-9]+)@.x\.jpg/\1/' `
      d="$f.imageset"
      echo "$fh > $d"
      if [ ! -d "$d" ] ; then
          mkdir -p  "$d"
          cat > "$d/Contents.json" <<EOM 
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "$f@1x.jpg",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "$f@2x.jpg",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "$f@3x.jpg",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "script"
  }
}
EOM
      fi
      mv "$fh" "$d"
  done


  # Add "Contents.json" for group
  cat > Contents.json <<EOM 
{
  "info" : {
    "version" : 1,
    "author" : "script"
  },
  "properties" : {
        "provides-namespace" : true
  }
}
EOM

  cd ..
fi

mkdir -p data
cd data

# Copy JSON data for each bird
if [ "x$COPY_BIRD_DATA" == xtrue ]; then
  echo "Copying bird data files..."
  cp -rcp ../../data/species/*.json .
fi
if [ "x$COPY_DATA" == xtrue ]; then
  echo "Copying vds data files..."
  cp -rcp ../../data/vds*.json .
fi
for fh in *.json ; do
    l=`echo "$fh" | sed -E 's/([a-z0-9-]+)-([a-z]{2})\.json/\2/' `
    f=`echo "$fh" | sed -E 's/([a-z0-9-]+)-([a-z]{2})\.json/\1/' `
    d="$l/$f.json.dataset"
    echo "$fh > $d"
    if [ $fh == 'Contents.json' ]; then
      echo "Skipping $fh"
    else
      if [ ! -d "$l" ] ; then
          mkdir -p  "$l"
          cat > "$l/Contents.json" <<EOM 
{
  "info" : {
    "version" : 1,
    "author" : "script"
  },
  "properties" : {
        "provides-namespace" : true
  }
}
EOM
      fi
      if [ ! -d "$d" ] ; then
          mkdir -p "$d"
          cat > "$d/Contents.json" <<EOM 
{
  "info" : {
    "version" : 1,
    "author" : "script"
  },
  "data" : [
    {
      "idiom" : "universal",
      "filename" : "$fh",
      "universal-type-identifier" : "public.json"
    },
  ]
}
EOM
      fi
      mv "$fh" "$d"
    fi
done

# Add "Contents.json" for group
cat > Contents.json <<EOM 
{
  "info" : {
    "version" : 1,
    "author" : "script"
  }
}
EOM


cd ..

# Add "Contents.json" for catalog
cat > Contents.json <<EOM 
{
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOM

#!/bin/sh

set -e
# set -x 

CUSTOMIZE_SVG=true

if [ "x$CUSTOMIZE_SVG" == xtrue ]; then
  echo "Customizing svg files..."

  cd svg/
  rm -rf customized
  mkdir -p customized
  
  cd download/
  for f in filter*.svg ; do 
      d="../customized/$f"
      echo "$f > $d"
      xmllint "../download/$f" --xpath '//*[local-name()="svg"]/child::*[local-name()!="mask"]'  \
        | sed \
        -e 's/stroke-width="2"/stroke-width="1.5"/g' \
        -e 's/<g mask[^>]+>//g' \
        -e 's/clip-rule="evenodd" //g' \
        > "../temp.xml"

      sed -e '/<!-- HERE IS YOUR PATH -->/ {' -e "r ../temp.xml" -e 'd' -e '}' "../../symbol-template.svg"  > "../customized/$f"
  done
  rm ../temp.xml

fi
cd ../..

# exit 0
###################################

mkdir -p Filter.xcassets
cd Filter.xcassets

# Copy customized svg files
echo "Copying customized svg files..."
cp -rcp ../svg/customized/*.svg .
for f in *.svg ; do 
    d="${f%.svg}.symbolset"
    echo "$f > $d"
    mkdir -p "$d"
    mv "$f" "$d"

    cat > "$d/Contents.json" <<EOM 
{
  "symbols" : [
    {
      "idiom" : "universal",
      "filename" : "$f"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "script"
  }
}
EOM
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

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
  for f in filter**.svg ; do 
      d="../customized/$f"
      echo "$f > $d"
      xmllint "../download/$f" --xpath '//*[local-name()="svg"]/child::*[local-name()!="title" and local-name()!="desc"]'  \
        | sed -e 's/fill="#FFFFFF"//g' \
        -e '/<mask/d' \
        -e '/<\/mask/d' \
        -e 's/<path d="M1,10.9973333 C1,16.52 5.48022222,21 11.0028889,21 C16.5255556,21 21,16.52 21,10.9973333 C21,5.47466667 16.5255556,1 11.0028889,1 C5.48022222,1 1,5.47466667 1,10.9973333 Z" id="Path" stroke="#000000" opacity="0.95"\/>//' \
        -e 's/<path d="M1 10.997C1 16.52 5.48 21 11.003 21S21 16.52 21 10.997A9.995 9.995 0 0 0 11.003 1C5.48 1 1 5.475 1 10.997z" stroke="#000" opacity=".95"\/>//' \
        -e 's/<path class="st0" d="M1 11c0 5.5 4.5 10 10 10s10-4.5 10-10S16.5 1 11 1 1 5.5 1 11z"\/>//' \
        -e 's/<path class="st0" d="M1 11c0 5.5 4.5 10 10 10s10-4.5 10-10S16.5 1 11 1 1 5.5 1 11z"\/>//' \
        -e 's/stroke-opacity="[0-9.]*" //' \
        > "../temp.xml"

      if [ "$f" == "filtervogelguppe-67.svg" ]; then 
        sed -i "" 's/a9490626802501180 9490626802501180/a/' ../temp.xml
      fi

      sed -e '/<!-- HERE IS YOUR PATH -->/ {' -e "r ../temp.xml" -e 'd' -e '}' "../../symbol-template.svg"  > "../customized/$f"
  done
  # rm ../temp.xml

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

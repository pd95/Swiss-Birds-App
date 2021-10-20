# UI Tests

This folder contains two kinds of UI tests and corresponding test plans:

- Functional tests to test functionality of all the screens
- Marketing tests to demo the app and take screenshots in the 4 supported languages

## UI test to produce marketing images

To produce the relevant marketing images for the AppStore, the marketing testplan can be executed on all relevant devices in parallel. The following script is booting the relevant devices, sets the status bar, runs the `Marketing` test plan and extracts the images into the `xcresult-parser` subdirectory.

```bash
#"iPad Pro (9.7-inch)"
DEVICES=(
    "iPhone Xs"
    "iPad Pro (12.9-inch) (4th generation)"
)
CONFIGURATIONS=( "German" "English" )

for device in $DEVICES ; do
    echo "> Booting $device"
    xcrun simctl boot "$device"
done
for device in $DEVICES ; do
    echo "> Set status bar for $device"
    xcrun simctl status_bar "$device" override --time "09:41 AM" --dataNetwork 4g --wifiMode active --wifiBars 3 --cellularMode notSupported --cellularBars 4 --operatorName ' ' --batteryState discharging 
done

DESTINATION_ARGS=( )
for device in $DEVICES ; do
    DESTINATION_ARGS=( $DESTINATION_ARGS -destination "platform=iOS Simulator,name=$device" )
done

CONFIGURATIONS_ARGS=( )
for configuration in $CONFIGURATIONS ; do
    CONFIGURATIONS_ARGS=( $CONFIGURATIONS_ARGS -only-test-configuration "$configuration" )
done

RESULT_BUNDLE="test-`date "+%Y-%m-%d-%H%M"`"
xcodebuild test -scheme "Swiss-Birds" -testPlan Snapshots -resultBundlePath xcresult-parser/$RESULT_BUNDLE -maximum-parallel-testing-workers 2 \
    $CONFIGURATIONS_ARGS \
    $DESTINATION_ARGS

cd xcresult-parser
node extract.js "$RESULT_BUNDLE"
cd ..
```

The tool to extract the relevant files from the result bundle is a Node.js utility in directory `xcresult-parser`.
This tool extracts for all devices (run destinations) the attachments (=currently screenshots) for the tests which were run.

The following snippet can be used to convert the PNG files into JPEG, dropping the attachment number and UUID of the filename:

```bash
set -o extendedglob
cd xcresult-parser
for device in $DEVICES ; do
    cd $device
    for f in *.png ; do 
        nf=${f//_?_[A-F0-9-]##.png/.jpeg}
        echo "$f -> $nf"
        sips -s format jpeg -s formatOptions low $f -o $nf
    done
    cd ..
done
cd ..
```

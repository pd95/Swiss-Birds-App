# UI Tests

This folder contains two kinds of UI tests and corresponding test plans:
- Functional tests to test functionality of all the screens
- Marketing tests to demo the app and take screenshots in the 4 supported languages 

##  UI test to produce marketing images

To produce the relevant marketing images for the AppStore, the marketing testplan can be executed on all relevant devices in parallel. The following script is booting the relevant devices, sets the status bar, runs the `Marketing` test plan and extracts the images into the `xcresult-parser` subdirectory.

```bash
DEVICES=(
    "iPhone 8 Plus" 
    "iPhone 11 Pro Max" 
    "iPad Pro (12.9-inch) (4th generation)" 
    "iPad Pro (12.9-inch) (2nd generation)"
)
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

RESULT_BUNDLE="test-`date "+%Y-%m-%d-%H%M"`"
xcodebuild test -scheme "Swiss-Birds" -testPlan Marketing -resultBundlePath xcresult-parser/$RESULT_BUNDLE \
    $DESTINATION_ARGS

cd xcresult-parser
node extract.js "$RESULT_BUNDLE"
```

The tool to extract the relevant files from the result bundle is a Node.js utility in directory `xcresult-parser`.
This tool extracts for all devices (run destinations) the attachments (=currently screenshots) for the tests which were run. 

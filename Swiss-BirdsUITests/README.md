# UI Tests

This folder contains two kinds of UI tests and corresponding test plans:
- Functional tests to test functionality of all the screens
- Marketing tests to demo the app and take screenshots in the 4 supported languages 

##  UI test to produce marketing images

To produce the relevant marketing images for the AppStore, the marketing testplan can be executed parallely on all relevant devices

    xcodebuild test -scheme "Swiss-Birds" -testPlan Marketing -resultBundlePath xcresult-parser/test5 \
        -destination "platform=iOS Simulator,name=iPhone 8 Plus" \
        -destination "platform=iOS Simulator,name=iPhone 11 Pro Max" \
        -destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (3rd generation)" \
        -destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation)"

The tool to extract the relevant files from the result bundle is a Node.js utility in directory `xcresult-parser`:

    node extract.js test5.xcresult

This tool extracts for all devices (run destinations) the attachments (=currently screenshots) for the tests which were run. 

Currently the iPad screenshots gathered are unusable, as they have been taken in a wrong device orientation.

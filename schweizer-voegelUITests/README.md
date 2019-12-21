# UI Tests

This folder contains two kinds of UI tests and corresponding test plans:
- Functional tests to test functionality of all the screens
- Marketing tests to demo the app and take screenshots in the 4 supported languages 

##  UI test to produce marketing images

To produce the relevant marketing images for the AppStore, the marketing testplan can be executed parallely on all relevant devices

    xcodebuild test -scheme "schweizer-voegel" -testPlan Marketing -resultBundlePath test4 \
        -destination "platform=iOS Simulator,name=iPhone 8 Plus" \
        -destination "platform=iOS Simulator,name=iPhone 11 Pro Max" \
        -destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (2nd generation)" \
        -destination "platform=iOS Simulator,name=iPad Pro (12.9-inch) (3rd generation)"

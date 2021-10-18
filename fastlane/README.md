fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios build_appstore
```
fastlane ios build_appstore
```
Build for AppStore submission
### ios lint
```
fastlane ios lint
```
Use swiftlint to check source quality and apply small fixes (`autocorrect` mode)
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios prepare_testing_build
```
fastlane ios prepare_testing_build
```
Build the app for screenshots creation and multiple installations from the same `build_Testing` location.
### ios take_screenshots
```
fastlane ios take_screenshots
```
Create screenshots for all configured languages and devices (based on `prepare_testing_build` lane) and frame them using a silver frame (if available)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

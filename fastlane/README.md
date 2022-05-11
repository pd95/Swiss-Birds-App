fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build_appstore

```sh
[bundle exec] fastlane ios build_appstore
```

Build for AppStore submission

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Use swiftlint to check source quality and apply small fixes (`autocorrect` mode)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new beta build to TestFlight

### ios prepare_testing_build

```sh
[bundle exec] fastlane ios prepare_testing_build
```

Build the app for screenshots creation and multiple installations from the same `build_Testing` location.

### ios take_screenshots

```sh
[bundle exec] fastlane ios take_screenshots
```

Create screenshots for all configured languages and devices (based on `prepare_testing_build` lane) and frame them using a silver frame (if available)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

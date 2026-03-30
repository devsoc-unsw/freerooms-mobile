# Freerooms iOS Mobile App

This is the native iOS mobile client for Freerooms. Freerooms is designed to help UNSW students easily find and browse available rooms and study spaces on campus. Built with speed, simplicity, and student experience in mind.

# Planned Features

For 2025 we're aiming to have the following features on iOS to reach parity with the web application:

- [] Check which rooms are free

- [] Sort and filter by a range of criteria

- [] See which buildings around you have free rooms on the map

- [] See the timetable for each room

- [] Quickly search for specific buildings or rooms

# Getting Started

## Prerequisites

- Xcode 16.3+

- iOS 17+ device or simulator

## Installation

1. Install Homebrew [here](https://brew.sh/)

2. Install SwiftLint:

```console
$ brew install swiftlint
```

3. Install SwiftFormat:

```console
$ brew install swiftformat
```

4. Clone the repo:

```console
$ git clone https://github.com/devsoc-unsw/freerooms-mobile.git
```

5. Install the custom git hooks (run the following commands from the `/freerooms-mobile` directory, not `/freerooms-mobile/ios`):

```console
$ chmod +x install-hooks.sh
$ ./install-hooks.sh
```

6. Open `Freerooms.xcodeproj` in Xcode

7. Build and run the app on a simulator or your device using the `Freerooms` scheme

# Linting and Formatting
This project uses [AirBnb's Swift style guide](https://github.com/airbnb/swift). SwiftLint and SwiftFormat are used to lint and format respectively, adhering to the style guide as closely as possible. After installation via Homebrew, they will run automatically on every build/commit/push.

To run them manually rather than on every build/commit/push, run the following commands in the `/ios` directory:
```console
$ swiftformat .
$ swiftlint
```

# Architecture

Refer to walkthrough on [Confluence](https://devsoc.atlassian.net/wiki/spaces/F/pages/349733080/Mobile+Architecturehttps://devsoc.atlassian.net/wiki/spaces/F/pages/349733080/Mobile+Architecture)

# Tests

To write tests, refer to testing strategy on [Confluence](https://devsoc.atlassian.net/wiki/spaces/F/pages/349798619/Test+Driven+Development)

To run tests, use the shortcut CMD + U (in Xcode)

# Contributing

1. Fork the repo

2. Create your feature branch

3. Commit your changes, using [conventional commit messages](https://www.conventionalcommits.org/en/v1.0.0/)

4. Push to the branch

5. Ensure all tests and linting/formatting are passing before opening a pull request

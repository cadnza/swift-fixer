# Swift Fixer

![](https://img.shields.io/github/v/release/cadnza/swift-fixer)

Swift formatter extension for Xcode 🔨

… Although, technically, this isn't actually a formatter—it's an Xcode extension that goes and gets your favorite formatter and applies it to your Swift code with a config file that lives somewhere on your machine.

|                                                                                                                            |                                                                                                                           |
| :------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------: |
| ![](https://github.com/cadnza/swift-fixer/blob/main/Swift%20Fixer/Assets.xcassets/Screenshots.imageset/light.png?raw=true) | ![](https://github.com/cadnza/swift-fixer/blob/main/Swift%20Fixer/Assets.xcassets/Screenshots.imageset/dark.png?raw=true) |

## Installation

[Download](https://github.com/cadnza/swift-fixer/releases/download/Swift_Fixer.app) the [latest release](https://github.com/cadnza/swift-fixer/releases).

## Setup

### Extension

Enable the Swift Fixer extension by checking **Swift Fixer** under **System Preferences** / **Extensions** / **Xcode Source Editor**.

### Configuration

Swift Fixer has three configurable parameters:

-   **Enabled**
    -   _Per formatter_
    -   Whether the selected formatter gets run when you run the Swift Fixer extension in Xcode.
-   **Linked Configuration**
    -   _Per formatter_
    -   The config file the selected formatter refers to when formatting your Swift in Xcode.
    -   Note that when you specify a config file, that file is _linked_, not imported. So when you specify `~/.swiftlint.yml` as Swift Lint's config file, future changes to `~/.swiftlint.yml` will take effect when you run the Swift Fixer extension in Xcode.
    -   Also note that you _must_ specify a configuration file in order to enable a formatter.
-   **Order**
    -   _General_
    -   The order in which enabled formatters are run.
    -   This is important because if you prefer to run two or more formatters to format your Swift code, the order in which those formatters run can affect the end result.
    -   You can specify an order by dragging and dropping cells in the application window.
    -   **Why would you ever want to run two consecutive formatters on your code?**
        -   About the only use case I can think of is running `swiftlint --fix` to clean up fixable linting messages that `swift-format` couldn't take care of. Beyond that, I have no idea why anyone would want to run two formatters. But hey, the capability's there. 🤷‍♂️

## Use

You can activate Swift Fixer in Xcode by clicking **Format Swift code** under **Editor** / **Swift Fixer**, but you'll probably find it more convenient to call with a keyboard shortcut, which can be configured through Xcode.

![ios](https://img.shields.io/badge/iOS-13-green)

# MailView

> Also available as a part of my [SwiftUI+ Collection](https://benkau.com/packages.json) – just add it to Xcode 13+

A SwiftUI view that enables you to properly present a `MFMailComposeViewController`.

## Features

-   Convenient modifier API
-   Correctly lays out full screen
-   Dedicated `Mail` type for constructing your mail

## Example

```swift
@State private var mail: Mail?

var body: some View {
    if Mail.canSendMail {
        Button {
            mail = Mail(
                to: "mail@foo.bar",
                subject: "...",
                message: .plainText("")
            )
        } label: {
            Text("Send email")
        }
        .mail($mail)
    }
}
```

## Installation

The code is packaged as a framework. You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/SwiftUI-Plus/MailView.git", .upToNextMinor(from: "1.0.0"))`

> Note: The package requires iOS v13+

## Other Packages

If you want easy access to this and more packages, add the following collection to your Xcode 13+ configuration:

`https://benkau.com/packages.json`

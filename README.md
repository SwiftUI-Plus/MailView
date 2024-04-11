![ios](https://img.shields.io/badge/iOS-13-green)

# MailView

A SwiftUI view that enables you to properly present the default email client composer for both iOS and macOS.

## Features

- Modern SwiftUI implementation.
- Structured approach with custom types for Mail, Message, Attachment.
- Full concurrency support for attachments with low-memory consumption.
- Support for `mailto` strings, so you can instantiate `Mail` using mailto value.
- Familiar API (similar to ShareLink, PasteButton, etc)

## Example

```swift
@State private var mail: Mail = .init(
    to: "foo@bar.com",
    subject: "Hello, world!",
    message: "Lorem ipsum...""
)

var body: some View {
    MailButton(mail: mail)
}
```

__Custom label__ 

```swift
var body: some View {
    MailButton(mail: mail) {
        Text("Custom label")
    }
}
```

__Mail is `ExpressibleByStringLiteral`__

```swift
// Create a `Mail` type with its `to` property set.
mail = "foo@bar.com"

// You can even pass an entire `mailto:` string:
mail = "mailto:foo@bar.com&subject=Foo&body=Bar"
```

## Installation

The code is packaged as a framework. You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/SwiftUI-Plus/MailView.git", .upToNextMinor(from: "2.0.0"))`

> Note: The package requires iOS v13+

## Other Packages

If you want easy access to this and more packages, add the following collection to your Xcode 13+ configuration:

`https://benkau.com/packages.json`

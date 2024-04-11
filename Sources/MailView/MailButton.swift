import SwiftUI

public typealias ResultHandler = (MailResult) -> Void

/// A view that controls a mail presentation.
///
/// Users tap or click on a mail button to present the default email client.
/// The button typically uses a system-standard appearance; you only
/// need to supply the mail content.
///
///     MailButton(to: "foo@bar.com")
///
/// You can control the appearance of the button by providing view content.
/// In addition you can use one othe convenience initializers to provide a
/// custom label and/or image.
///
///     MailButton("Send email", "systemImage: "envelope.ciurcle", item: "foo@bar.com")
///
/// If sending the email fails, by default, a system alert will be presented
/// with the associated error.
///
/// You can override this behaviour by providing your own result handler:
///
///     MailButton(to: "foo@bar.com")
///         .onMailResult { result in
///             print(result)
///         }
///
/// - Note: If the device does not have a default mail client configured
/// for sending email, the button will be disabled automatically. Therefore
/// the button will always be __disabled__ when running on the __iOS Simulator__.
///
public struct MailButton<Label: View>: View {
    @Environment(\.openURL) private var openUrl
    @Environment(\.mailResult) private var resultHandler

#if os(macOS)
    @StateObject private var service: MailService = .init()
#endif

    @State private var isPresented: Bool = false
    @State private var isDisabled: Bool = false

    @State private var error: MailError?
    @State private var showError: Bool = false

    private var internalResultHandler: ResultHandler {
        resultHandler ?? { result in
            if case let .failed(error) = result {
                self.error = error
                showError = true
            }
        }
    }

    private let label: Label
    private var item: Mail

    public init(item: Mail, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.item = item
    }

    public var body: some View {
        Button {
#if os(iOS)
            isPresented = true
#else
            Task {
                try await service.send(item: item, handler: internalResultHandler)
            }
#endif
        } label: {
            label
        }
#if os(iOS)
        .background(
            MailView(
                mail: item,
                isPresented: $isPresented,
                onResult: internalResultHandler
            )
        )
#endif
        .disabled(!Mail.isSupported)
        .alert(isPresented: $showError, error: error)
    }
}

private extension View {
    @ViewBuilder
    func alert(isPresented: Binding<Bool>, error: MailError?) -> some View {
        if #available(iOS 15, macOS 12, *) {
            alert(Text("Failed"), isPresented: isPresented, presenting: error) { _ in
                Button("OK") { }
            } message: { error in
                Text(error.localizedDescription)
            }
        } else {
            alert(isPresented: isPresented) {
                Alert(
                    title: Text("Email failed"),
                    message: Text((error ?? .failedToSend).localizedDescription),
                    dismissButton: .cancel()
                )
            }
        }
    }
}

public extension MailButton where Label == SwiftUI.Label<Text, Image> {
    init(item: Mail) {
        self.label = Label("Email", systemImage: "envelope")
        self.item = item
    }

    init(_ titleKey: LocalizedStringKey, systemImage: String, item: Mail) {
        label = Label(titleKey, systemImage: systemImage)
        self.item = item
    }

    init(_ title: some StringProtocol, systemImage: String, item: Mail) {
        label = Label(title, systemImage: systemImage)
        self.item = item
    }

    init(_ titleKey: LocalizedStringKey, image: String, item: Mail) {
        label = Label(titleKey, image: image)
        self.item = item
    }

    init(_ title: some StringProtocol, image: String, item: Mail) {
        label = Label(title, image: image)
        self.item = item
    }
}

public extension MailButton where Label == SwiftUI.Label<Text, Image> {
    init(to: Address..., subject: String = "", message: Message = "") {
        self.init(item: .init(to: to, subject: subject, message: message))
    }
}

public extension MailButton where Label == Text {
    init(_ titleKey: LocalizedStringKey, item: Mail) {
        label = Text(titleKey)
        self.item = item
    }

    init(_ title: some StringProtocol, item: Mail) {
        label = Text(title)
        self.item = item
    }
}

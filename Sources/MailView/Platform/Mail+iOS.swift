#if os(iOS)
import SwiftUI
import MessageUI
import UniformTypeIdentifiers

internal struct MailView: UIViewControllerRepresentable {
    private let mail: Mail
    @Binding private var isPresented: Bool
    private var handler: ResultHandler?

    init(mail: Mail, isPresented: Binding<Bool>, onResult handler: ResultHandler?) {
        self.mail = mail
        self.handler = handler
        _isPresented = isPresented
    }

    func makeUIViewController(context: Context) -> Controller {
        Controller(mail: mail, isPresented: $isPresented, handler: handler)
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.mail = mail
        controller.isPresented = $isPresented
        controller.handler = handler
    }
}

internal extension MailView {
    final class Controller: UIViewController, MFMailComposeViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
        private weak var controller: UIViewController?
        private weak var _delegate: UIAdaptivePresentationControllerDelegate?

        fileprivate var mail: Mail
        fileprivate var handler: ResultHandler?
        fileprivate var isPresented: Binding<Bool> {
            didSet {
                updateLifecycle(
                    from: oldValue.wrappedValue,
                    to: isPresented.wrappedValue
                )
            }
        }

        init(mail: Mail, isPresented: Binding<Bool>, handler: ResultHandler?) {
            self.mail = mail
            self.handler = handler
            self.isPresented = isPresented
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func updateLifecycle(from oldValue: Bool, to newValue: Bool) {
            switch (oldValue, newValue) {
            case (false, true):
                presentController()
            case (true, false):
                dismissController()
            case (true, true), (false, false):
                break
            }
        }

        private func presentController() {
            guard Mail.isSupported else {
                handler?(.failed(.unsupported))
                isPresented.wrappedValue = false
                return
            }

            Task {
                do {
                    let controller = MFMailComposeViewController()
                    controller.mailComposeDelegate = self
                    self.controller = controller

                    try await mail.attachments.concurrentForEach {
                        let url = try $0.url()
                        let data = try Data(contentsOf: url, options: .mappedIfSafe)

                        controller.addAttachmentData(
                            data,
                            mimeType: $0.contentType.preferredMIMEType ?? "text/plain",
                            fileName: $0.filename
                        )
                    }

                    controller.setSubject(mail.subject)
                    controller.setMessageBody(mail.message.rawValue, isHTML: mail.message.isHTML)
                    controller.setToRecipients(mail.to.map { $0.rawValue })
                    controller.setCcRecipients(mail.cc.map { $0.rawValue })
                    controller.setBccRecipients(mail.bcc.map { $0.rawValue })

                    if let from = mail.from?.rawValue {
                        controller.setPreferredSendingEmailAddress(from)
                    }

                    let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
                    let window = scene?.windows.first { $0.isKeyWindow }
                    window?.rootViewController?.present(controller, animated: true, completion: nil)

                    _delegate = controller.presentationController?.delegate
                    controller.presentationController?.delegate = self
                } catch {
                    handler?(.failed(.other(error)))
                    dismissController()
                    return
                }
            }
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            _delegate?.presentationControllerDidDismiss?(presentationController)
            dismissController()
        }

        override func responds(to aSelector: Selector!) -> Bool {
            if super.responds(to: aSelector) { return true }
            if _delegate?.responds(to: aSelector) ?? false { return true }
            return false
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if super.responds(to: aSelector) { return self }
            return _delegate
        }

        private func dismissController() {
            guard let controller else { return }
            controller.presentingViewController?.dismiss(animated: true)
            DispatchQueue.main.async {
                self.isPresented.wrappedValue = false
            }
        }

        @objc public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            handler?(.init(result, error: error))
            dismissController()
        }
    }
}

public extension View {
    /// Presents an email composer when the associated `Mail` is present
    /// - Parameters:
    ///   - mail: The mail to be sent
    ///   - onComplete: When the email composer is dimissed, this will be called with the result
    @available(swift, obsoleted: 1, message: "Use `MailButton` instead")
    func mail(_ mail: Binding<Mail?>, onResult handler: ResultHandler? = nil) -> some View {
        background(
            MailView(
                mail: mail.wrappedValue ?? .init(to: ""),
                isPresented: .init(
                    get: { mail.wrappedValue != nil },
                    set: {
                        if !$0 { mail.wrappedValue = nil }
                    }
                ),
                onResult: handler
            )
        )
    }
}
#endif

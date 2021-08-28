import SwiftUI
import MessageUI

public extension View {

    /// Presents an email composer when the associated `Mail` is present
    /// - Parameters:
    ///   - mail: The mail to be sent
    ///   - onComplete: When the email composer is dimissed, this will be called with the result
    func mail(_ mail: Binding<Mail?>, onComplete: MailResult? = nil) -> some View {
        background(MailView(mail: mail, onComplete: onComplete))
    }

}

public typealias MailResult = (MFMailComposeResult) -> Void

private struct MailView: UIViewControllerRepresentable {

    @Binding private var mail: Mail?
    private var completion: MailResult?

    public init(mail: Binding<Mail?>, onComplete: MailResult? = nil) {
        _mail = mail
        self.completion = onComplete
    }

    public func makeUIViewController(context: Context) -> MailViewControllerWrapper {
        MailViewControllerWrapper(mail: $mail, completion: completion)
    }

    public func updateUIViewController(_ controller: MailViewControllerWrapper, context: Context) {
        controller.mail = $mail
        controller.completion = completion
        controller.updateState()
    }

}

private final class MailViewControllerWrapper: UIViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {

    fileprivate var mail: Binding<Mail?>
    fileprivate var completion: MailResult?

    init(mail: Binding<Mail?>, completion: MailResult?) {
        self.mail = mail
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        let isActivityPresented = presentedViewController != nil

        if mail.wrappedValue != nil {
            if !isActivityPresented {
                let controller = MFMailComposeViewController()

                controller.setSubject(mail.wrappedValue?.subject ?? "")
                controller.setMessageBody(mail.wrappedValue?.message?.text ?? "", isHTML: mail.wrappedValue?.message?.isHTML ?? false)
                controller.setToRecipients(mail.wrappedValue?.to.map { $0.rawValue })
                controller.setCcRecipients(mail.wrappedValue?.cc.map { $0.rawValue })
                controller.setBccRecipients(mail.wrappedValue?.bcc.map { $0.rawValue })
                controller.setPreferredSendingEmailAddress(mail.wrappedValue?.preferredSendingAddress?.rawValue ?? "")

                mail.wrappedValue?.attachments.forEach {
                    controller.addAttachmentData($0.data, mimeType: $0.mimeType, fileName: $0.preferredFilename)
                }

                controller.mailComposeDelegate = self
                controller.popoverPresentationController?.sourceView = view
                present(controller, animated: true, completion: nil)
            }
        }
    }

    @objc public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
        mail.wrappedValue = nil
        completion?(result)
    }

}

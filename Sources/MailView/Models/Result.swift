import Foundation
#if canImport(MessageUI)
import MessageUI
#endif

/// Represents the result of attempting to send mail
public enum MailResult: Equatable {
    /// The email message was queued in the user’s outbox.
    case sent
    /// The email message was saved in the user’s drafts folder.
    case saved
    /// The user canceled the operation.
    case cancelled
    /// The email message was not saved or queued, possibly due to an error.
    case failed(MailError?)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.sent, .sent):
            return true
        case (.saved, .saved):
            return true
        case (.cancelled, .cancelled):
            return true
        case let (.failed(lhs), .failed(rhs)):
            if lhs == nil, rhs == nil { return true }
            guard let lhs, let rhs else { return false }
            return (lhs as NSError).code == (rhs as NSError).code
        default:
            return false
        }
    }

#if canImport(MessageUI)
    internal init(_ result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent: self = .sent
        case .saved: self = .saved
        case .cancelled: self = .cancelled
        case .failed: self = .failed(.other(error))
        @unknown default: self = .sent
        }
    }
#endif
}

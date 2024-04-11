import Foundation

public enum MailError: LocalizedError {
    case failedToSend
    case unsupported
    case other(Error?)

    public var errorDescription: String? {
        switch self {
        case .unsupported:
            "Email is not supported on this device. Check that an email client has been setup correctly."
        case .failedToSend:
            "The email could not be sent."
        case .other(let error):
            error?.localizedDescription ?? "Email failed, an unknown error occurred."
        }
    }
}

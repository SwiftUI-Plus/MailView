import Foundation
import MessageUI

/// Represents a mail message
public struct Mail: Codable {

    /// Represents an email address
    public struct Address: Codable, ExpressibleByStringLiteral {
        internal let rawValue: String

        public init(email: String) {
            self.rawValue = email
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }

    /// Represents an attachement associated with a `Mail` instance
    public struct Attachment: Codable {
        public let data: Data
        public let mimeType: String
        public let preferredFilename: String

        /// Makes a new attachment to be associated with a `Mail` instance
        /// - Parameters:
        ///   - data: The underlying data representation of this attachment
        ///   - mimeType: The mime/uniform type identifier representing the data in this attachment
        ///   - preferredFilename: The preferred filename to use for this attachment
        public init(data: Data, mimeType: String, preferredFilename: String) {
            self.data = data
            self.mimeType = mimeType
            self.preferredFilename = preferredFilename
        }
    }

    /// Represents teh message associated with a `Mail` instance
    public enum Message: Codable, ExpressibleByStringLiteral {
        /// The message text will be interpreted as plain text
        case plainText(String)
        /// The message text will be interpreted as HTML content
        case html(String)

        internal var isHTML: Bool {
            switch self {
            case .plainText: return false
            case .html: return true
            }
        }

        internal var text: String {
            switch self {
            case let .plainText(text),
                let .html(text):
                return text
            }
        }

        public init(stringLiteral value: String) {
            self = .plainText(value)
        }
    }

    /// The subject of this `Mail`
    public var subject: String?
    /// The message of this `Mail`
    public var message: Message?
    /// The 'to' recipients of this `Mail`
    public var to: [Address] = []
    /// The 'cc' recipients of this `Mail`
    public var cc: [Address] = []
    /// The 'bcc' recipients of this `Mail`
    public var bcc: [Address] = []
    /// The preferred 'sender' of this `Mail`
    public var preferredSendingAddress: Address?
    /// The attachments associated with this `Mail`
    public var attachments: [Attachment] = []

    public init() { }

    /// Makes a new `Mail` instance with the defined `to`, `subject` and `message` values
    /// - Parameters:
    ///   - to: The 'to' recipients of this `Mail`
    ///   - subject: The subject of this `Mail`
    ///   - message: The message of this `Mail`
    public init(to: Address..., subject: String = "", message: Message = .plainText("")) {
        self.to = to
        self.subject = subject
        self.message = message
    }
}

public extension Mail {

    /// Returns true is mail can be sent from this device
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

}

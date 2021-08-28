import Foundation
import MessageUI

public struct Mail: Codable {

    public struct Address: Codable, RawRepresentable, ExpressibleByStringLiteral {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(email: String) {
            self.rawValue = email
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }

    public struct Attachment: Codable {
        public let data: Data
        public let mimeType: String
        public let preferredFilename: String

        public init(data: Data, mimeType: String, preferredFilename: String) {
            self.data = data
            self.mimeType = mimeType
            self.preferredFilename = preferredFilename
        }
    }

    public enum Message: Codable, ExpressibleByStringLiteral {
        case plainText(String)
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

    public var subject: String?
    public var message: Message?
    public var to: [Address] = []
    public var cc: [Address] = []
    public var bcc: [Address] = []
    public var preferredSendingAddress: Address?
    public var attachments: [Attachment] = []

    public init() { }

    public init(to: Address..., subject: String = "", message: Message = .plainText("")) {
        self.to = to
        self.subject = subject
        self.message = message
    }
}

public extension Mail {

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

}

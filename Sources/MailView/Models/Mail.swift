import SwiftUI

/// Represents a mail message
public struct Mail: Codable, Sendable, ExpressibleByStringLiteral, Hashable {
    /// The 'to' recipients of this `Mail`
    public var to: [Address] = []

    /// The 'cc' recipients of this `Mail`
    ///
    /// - Note: This value is only supported on iOS
    public var cc: [Address] = []
    
    /// The 'bcc' recipients of this `Mail`
    ///
    /// - Note: This value is only supported on iOS
    public var bcc: [Address] = []
    
    /// The preferred 'sender' of this `Mail`
    ///
    /// - Note: This value is only supported on iOS
    public var from: Address?
    
    /// The subject of this `Mail`
    public var subject: String = ""
    
    /// The message of this `Mail`
    public var message: Message = ""
    
    /// The attachments associated with this `Mail`
    public var attachments: [Attachment] = []

    @available(swift, deprecated: 1, renamed: "from")
    public var preferredSendingAddress: Address? { from }

    public init() { }

    public init(mailto value: some StringProtocol) {
        var value = String(value)
        if !value.hasPrefix("mailto:") {
            value = "mailto:\(value)"
        }

        func addresses(in value: String?) -> [Address] {
            guard let value else { return [] }
            return value.replacingOccurrences(of: " ", with: "")
                .components(separatedBy: ",")
                .map { .init($0) }
        }

        let comps = URLComponents(string: value)
        let queries = comps?.queryItems ?? []

        to = addresses(in: comps?.path ?? "")
        cc = queries.all(named: "cc").flatMap { addresses(in: $0.value) }
        bcc = queries.all(named: "bcc").flatMap { addresses(in: $0.value) }

        if let value = queries["subject"]?.value {
            subject = value
        }

        if let body = queries["body"]?.value {
            message = .plainText(body)
        }
    }

    public init(stringLiteral value: String) {
        self.init(mailto: value)
    }

    /// Makes a new `Mail` instance with the defined `to`, `subject` and `message` values
    /// - Parameters:
    ///   - to: The 'to' recipients of this `Mail`
    ///   - cc: The 'cc' recipients of this `Mail`
    ///   - bcc: The 'bcc' recipients of this `Mail`
    ///   - subject: The subject of this `Mail`
    ///   - message: The message of this `Mail`
    public init(
        to: [Address],
        cc: [Address] = [],
        bcc: [Address] = [],
        from: Address? = nil,
        subject: String = "", 
        message: Message = .plainText(""),
        attachments: [Attachment] = []
    ) {
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.from = from
        self.subject = subject
        self.message = message
        self.attachments = attachments
    }

    /// Makes a new `Mail` instance with the defined `to`, `subject` and `message` values
    /// - Parameters:
    ///   - to: The 'to' recipients of this `Mail`
    ///   - cc: The 'cc' recipients of this `Mail`
    ///   - bcc: The 'bcc' recipients of this `Mail`
    ///   - subject: The subject of this `Mail`
    ///   - message: The message of this `Mail`
    public init(
        to: Address...,
        cc: [Address] = [],
        bcc: [Address] = [],
        from: Address? = nil,
        subject: String = "",
        message: Message = .plainText(""),
        attachments: [Attachment] = []
    ) {
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.from = from
        self.subject = subject
        self.message = message
        self.attachments = attachments
    }

    public var mailto: String {
        var value = "mailto:"
        var queries: [String] = []

        if !to.isEmpty {
            value += to.map { $0.rawValue }.joined(separator: ",")
        }

        if !cc.isEmpty {
            queries.append("cc=" + cc.map { $0.rawValue }.joined(separator: ","))
        }

        if !bcc.isEmpty {
            queries.append("bcc=" + bcc.map { $0.rawValue }.joined(separator: ","))
        }

        if let subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !subject.isEmpty {
            queries.append("subject=" + subject)
        }

        if case .plainText(let string) = message, let string = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !string.isEmpty {
            queries.append("body=" + string)
        }

        if queries.isEmpty {
            return value
        } else {
            return value + "?" + queries.joined(separator: "&")
        }
    }
}

#if canImport(MessageUI)
import MessageUI
#endif

public extension Mail {
    /// Returns true is mail can be sent from this device
    static var isSupported: Bool {
#if os(iOS)
        MFMailComposeViewController.canSendMail()
#else
        NSSharingService(named: .composeEmail) != nil
#endif
    }

    @available(swift, deprecated: 1, renamed: "supported")
    static var canSendMail: Bool {
        isSupported
    }
}

import Foundation

/// Represents teh message associated with a `Mail` instance
public enum Message: Codable, ExpressibleByStringLiteral, Sendable, CustomStringConvertible, Hashable, RawRepresentable {
    /// The message text will be interpreted as plain text
    case plainText(String)
    /// The message text will be interpreted as HTML content
    case html(String)

    public var isHTML: Bool {
        switch self {
        case .plainText: return false
        case .html: return true
        }
    }

    public var rawValue: String {
        switch self {
        case let .plainText(text),
            let .html(text):
            return text
        }
    }
    
    /// Instantiates a new message as plain text
    /// - Parameter rawValue: The plain text that represents this message
    public init(_ rawValue: String) {
        self = .plainText(rawValue)
    }

    /// Instantiates a new message as plain text
    /// - Parameter rawValue: The plain text that represents this message
    public init(rawValue: String) {
        self = .plainText(rawValue)
    }

    /// Instantiates a new message as plain text
    /// - Parameter rawValue: The plain text that represents this message
    public init(stringLiteral value: String) {
        self = .plainText(value)
    }

    public var description: String { rawValue }
}

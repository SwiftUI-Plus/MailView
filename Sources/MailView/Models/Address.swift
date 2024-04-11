import Foundation

/// Represents an email address
public struct Address: Codable, ExpressibleByStringLiteral, Sendable, CustomStringConvertible, Identifiable, Hashable, RawRepresentable {
    public var id: String { rawValue }
    public let rawValue: String
    
    /// Instantiates with the specified email address
    /// - Parameter rawValue: The email this address represents
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Instantiates with the specified email address
    /// - Parameter rawValue: The email this address represents
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Instantiates with the specified email address
    /// - Parameter value: The email this address represents
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public var description: String { rawValue }

    @available(swift, deprecated: 1, renamed: "init(_:)")
    public init(email: String) {
        self.rawValue = email
    }
}

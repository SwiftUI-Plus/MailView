import Foundation
import UniformTypeIdentifiers

internal extension URL {
    init(filename: String) {
        let url = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self = url.appendingPathComponent(filename)
    }
}

import Foundation

extension Collection where Element == URLQueryItem {
    func all(named name: String) -> [Element] {
        filter { $0.name == name }
    }
    
    subscript(_ name: String) -> Element? {
        first { $0.name == name }
    }
}

import Foundation

extension Optional {
    public func flatMap<U>(_ transform: (Wrapped) async throws -> U?) async rethrows -> U? {
        switch self {
        case .some(let wrapped):
            return try await transform(wrapped)
        case .none:
            return nil
        }
    }
}

public extension Sequence {
    func forEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

public extension Sequence {
    func compactMap<ElementOfResult>(_ transform: (Element) async throws -> ElementOfResult?) async rethrows -> [ElementOfResult] {
        var result: [ElementOfResult] = []

        for element in self {
            if let element = try await transform(element) {
                result.append(element)
            }
        }

        return result
    }
}

public extension Sequence {
    func map<ElementOfResult>(_ transform: (Element) async throws -> ElementOfResult) async rethrows -> [ElementOfResult] {
        var result: [ElementOfResult] = []

        for element in self {
            try await result.append(transform(element))
        }

        return result
    }
}

public extension Sequence {
    func concurrentForEach(_ operation: @escaping (Element) async throws -> Void) async rethrows {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel
        await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    try await operation(element)
                }
            }
        }
    }
}

public extension Sequence {
    func concurrentMap<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.map { task in
            try await task.value
        }
    }
}

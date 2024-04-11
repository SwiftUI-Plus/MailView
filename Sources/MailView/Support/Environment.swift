import SwiftUI

public extension View {
    func onMailResult(handler: @escaping ResultHandler) -> some View {
        environment(\.mailResult, handler)
    }
}

internal extension EnvironmentValues {
    struct MailResultEnvironmentKey: EnvironmentKey {
        public static var defaultValue: ResultHandler?
    }

    var mailResult: MailResultEnvironmentKey.Value {
        get { self[MailResultEnvironmentKey.self] }
        set { self[MailResultEnvironmentKey.self] = newValue }
    }
}


import SwiftUI

#if os(macOS)
@MainActor
final class MailService: NSObject, NSSharingServiceDelegate, ObservableObject {
    private let service: NSSharingService?
    private var handler: ResultHandler = { _ in }

    override init() {
        self.service = NSSharingService(named: .composeEmail)
        super.init()
        service?.delegate = self
    }

    func send(item: Mail, handler: @escaping ResultHandler) async throws {
        guard Mail.isSupported else { throw MailError.unsupported }
        self.handler = handler

        service?.subject = item.subject
        service?.recipients = item.to.map { $0.rawValue }

        var items: [Any] = try item.attachments.map { try $0.url() }
        items.insert(item.message.rawValue, at: 0)

        service?.perform(withItems: items)
    }

    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        handler(.sent)
    }

    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: any Error) {
        handler(.failed(.other(error)))
    }
}
#endif

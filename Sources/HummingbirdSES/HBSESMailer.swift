import HummingbirdMail
import FeatherSESMail
import SotoSESv2

struct HBSESMailer: HBMailer {

    let ses: SESv2
    let logger: Logger
    let eventLoop: EventLoop
    
    func send(_ email: HBMail) async throws {
        try await FeatherSESMailer(
            ses: ses,
            logger: logger,
            eventLoop: eventLoop
        )
        .send(email)
    }
}

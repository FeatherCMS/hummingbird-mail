import FeatherSMTPMail
import HummingbirdMail
import Logging
import NIOCore
import NIOSMTP

struct HBSMTPMailer: HBMailer {

    let smtp: NIOSMTP
    let logger: Logger
    let eventLoop: EventLoop

    func send(_ email: HBMail) async throws {
        try await FeatherSMTPMailer(
            smtp: smtp,
            logger: logger,
            eventLoop: eventLoop
        )
        .send(email)
    }
}

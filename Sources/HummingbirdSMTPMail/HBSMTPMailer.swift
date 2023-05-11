import HummingbirdMail
import NIOSMTP
import NIOCore
import Logging
import FeatherSMTPMail

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

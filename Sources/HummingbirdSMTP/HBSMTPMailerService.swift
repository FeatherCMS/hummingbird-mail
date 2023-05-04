import NIO
import NIOSMTP
import Logging
import HummingbirdMail

struct HBSMTPMailerService: HBMailerService {

    let smtp: NIOSMTP
    
    init(
        eventLoopGroup: EventLoopGroup,
        hostname: String,
        port: Int = 587,
        signInMethod: SignInMethod = .anonymous,
        security: SMTPSecurity = .startTLS,
        timeout: TimeAmount = .seconds(10),
        helloMethod: HelloMethod = .helo,
        logger: Logger? = nil
    ) {
        let configuration = SMTPConfiguration(
            hostname: hostname,
            port: port,
            signInMethod: signInMethod,
            security: security,
            timeout: timeout,
            helloMethod: helloMethod
        )
        self.smtp = .init(
            eventLoopGroup: eventLoopGroup,
            configuration: configuration,
            logger: logger
        )
    }

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBMailer {
        HBSMTPMailer(
            service: self,
            logger: logger,
            eventLoop: eventLoop
        )
    }
}

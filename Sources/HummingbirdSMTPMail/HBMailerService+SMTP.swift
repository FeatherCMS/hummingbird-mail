import Hummingbird
import HummingbirdMail
import HummingbirdServices
import Logging
import NIOSMTP

extension HBApplication.Services {

    public func setUpSMTPMailer(
        eventLoopGroup: EventLoopGroup,
        hostname: String,
        port: Int = 587,
        signInMethod: SignInMethod = .anonymous,
        security: SMTPSecurity = .startTLS,
        timeout: TimeAmount = .seconds(10),
        helloMethod: HelloMethod = .helo,
        logger: Logger? = nil
    ) {
        mailer = HBSMTPMailerService(
            eventLoopGroup: eventLoopGroup,
            hostname: hostname,
            port: port,
            signInMethod: signInMethod,
            security: security,
            timeout: timeout,
            helloMethod: helloMethod,
            logger: logger
        )
    }
}

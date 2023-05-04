import Hummingbird
import HummingbirdServices
import HummingbirdMail
import Logging
@_exported import NIOSMTP


public extension HBApplication.Services {

    func setUpSMTPMailer(
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

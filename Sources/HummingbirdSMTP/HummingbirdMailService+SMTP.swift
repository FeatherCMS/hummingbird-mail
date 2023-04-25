import NIO
import NIOSMTP
import Logging
import HummingbirdMail

public extension HummingbirdMailService where Self == NIOSMTP {

    static func smtp(
        eventLoopGroup: EventLoopGroup,
        hostname: String,
        port: Int = 587,
        signInMethod: SignInMethod = .anonymous,
        security: SMTPSecurity = .startTLS,
        timeout: TimeAmount = .seconds(10),
        helloMethod: HelloMethod = .helo,
        logger: Logger? = nil
    ) -> HummingbirdMailService {
        let configuration = SMTPConfiguration(
            hostname: hostname,
            port: port,
            signInMethod: signInMethod,
            security: security,
            timeout: timeout,
            helloMethod: helloMethod
        )
        return NIOSMTP(
            eventLoopGroup: eventLoopGroup,
            configuration: configuration,
            logger: logger
        )
    }
}

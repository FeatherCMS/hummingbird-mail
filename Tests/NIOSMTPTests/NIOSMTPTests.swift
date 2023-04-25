import XCTest
import NIO
import NIOSMTP
import Logging

final class NIOSMTPTests: XCTestCase {
    
    func testSMTP() async throws {
        let env = ProcessInfo.processInfo.environment

        let configuration = SMTPConfiguration(
            hostname: env["SMTP_HOST"]!,
            port: 587,
            signInMethod: .credentials(
                username: env["SMTP_USER"]!,
                password: env["SMTP_PASS"]!
            ),
            security: .startTLS
        )

        let email = try SMTPMail(
            from: SMTPAddress(env["SMTP_FROM"]!),
            to: [
                SMTPAddress(env["SMTP_TO"]!),
            ],
            subject: "test smtp",
            body: "This is a <b>SMTP</b> test email body.",
            isHtml: true
        )

        let eventLoopGroup = MultiThreadedEventLoopGroup(
            numberOfThreads: 1
        )
        let smtp = NIOSMTP(
            eventLoopGroup: eventLoopGroup,
            configuration: configuration,
            logger: .init(label: "nio-smtp")
        )
        try await smtp.send(email)
        try smtp.shutdown()
    }
}

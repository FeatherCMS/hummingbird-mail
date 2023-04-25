import XCTest
import NIO
import Hummingbird
import HummingbirdMail
import HummingbirdSMTP
import Logging

final class HummingbirdMTPTests: XCTestCase {
    
    func testSMTP() async throws {
        let env = ProcessInfo.processInfo.environment

        let app = HBApplication()
        app.mail.sender = .smtp(
            eventLoopGroup: app.eventLoopGroup,
            hostname: env["SMTP_HOST"]!,
            signInMethod: .credentials(
                username: env["SMTP_USER"]!,
                password: env["SMTP_PASS"]!
            )
        )

        let email = try Email(
            from: Address(env["MAIL_FROM"]!),
            to: [
                Address(env["MAIL_TO"]!),
            ],
            subject: "test smtp",
            body: "This is a <b>SMTP</b> test email body.",
            isHtml: true
        )

        try await app.mail.sender.send(email)
        try app.shutdownApplication()
    }
}

import MailKit
import NIO
import SES
import SMTP
import SotoCore
import XCTest

final class HBMailTests: XCTestCase {

    func testSMTP() async throws {
        let configuration = SMTPServerConfiguration(
            hostname: "#Your SMTP host#",
            signInMethod: .credentials(
                username: "#Your SMTP username#",
                password: "#Your SMTP password#"
            )
        )

        let email = try Email(
            from: EmailAddress(address: "from@example.com"),
            to: [EmailAddress(address: "to@example.com")],
            subject: "test smtp",
            body: "This is a <b>SMTP</b> test email body.",
            isBodyHtml: true
        )

        let eventLoopGroup = MultiThreadedEventLoopGroup(
            numberOfThreads: System.coreCount
        )
        let sender = SMTPSender(
            eventLoopGroup: eventLoopGroup,
            configuration: configuration
        )
        try await sender.send(email) { message in print(message) }
        try sender.shutdown()
    }

    func testSES() async throws {
        let email = try Email(
            from: EmailAddress(address: "from@example.com"),
            to: [EmailAddress(address: "to@example.com")],
            subject: "test ses smtp",
            body: "This is a <b>SES</b> test email body.",
            isBodyHtml: true
        )

        let logger = Logger(label: "aws-logger")
        let eventLoopGroup = MultiThreadedEventLoopGroup(
            numberOfThreads: System.coreCount
        )
        let client = AWSClient.init(
            credentialProvider: .static(
                accessKeyId: "#Your SES access key#",
                secretAccessKey: "#Your SES secret access key#"
            ),
            httpClientProvider: .createNewWithEventLoopGroup(
                eventLoopGroup
            ),
            logger: logger
        )
        let sender = SESSender(
            client: client,
            region: .uswest1
        )
        print(try await sender.send(email))
        try client.syncShutdown()
    }

}

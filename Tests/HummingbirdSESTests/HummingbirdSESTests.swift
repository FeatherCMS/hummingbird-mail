import XCTest
import NIO
import Hummingbird
import HummingbirdMail
import HummingbirdSES
import SotoCore
import Logging

final class HummingbirdMTPTests: XCTestCase {
    
    func testSMTP() async throws {
        let env = ProcessInfo.processInfo.environment

        var logger = Logger(label: "aws-logger")
        logger.logLevel = .info
        
        let app = HBApplication()
        app.aws.client = .init(
            credentialProvider: .static(
                accessKeyId: env["SES_ID"]!,
                secretAccessKey: env["SES_SECRET"]!
            ),
            options: .init(
                requestLogLevel: .info,
                errorLogLevel: .info
            ),
            httpClientProvider: .createNewWithEventLoopGroup(
                app.eventLoopGroup
            ),
            logger: logger
        )

        app.mail.sender = .ses(
            client: app.aws.client,
            region: .init(awsRegionName: env["SES_REGION"]!)!
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

import XCTest
import NIO
import Hummingbird
import HummingbirdMail
import HummingbirdSES
import SotoCore
import Logging

final class HummingbirdSESTests: XCTestCase {
    
    private let testFrom = "#add test email#"
    private let testTo = "#add test email#"
    
    func testSimpleText() async throws {
        let email = try Email(
            from: Address(testFrom),
            to: [
                Address(testTo),
            ],
            subject: "test ses with simple text",
            body: "This is a simple text email body with SES."
        )
        
        try await testSES(email)
    }
    
    func testHMTLText() async throws {
        let email = try Email(
            from: Address(testFrom),
            to: [
                Address(testTo),
            ],
            subject: "test ses with HTML text",
            body: "This is a <b>HTML text</b> email body with SES.",
            isHtml: true
        )
        
        try await testSES(email)
    }
    
    func testAttachment() async throws {
        let packageRootPath = URL(fileURLWithPath: #file)
                                .pathComponents
                                .prefix(while: { $0 != "Tests" })
                                .joined(separator: "/")
                                .dropFirst()
        let assetsUrl = URL(fileURLWithPath: String(packageRootPath)).appendingPathComponent("Tests")
                                                                     .appendingPathComponent("Assets")
        let testData = try Data(contentsOf: assetsUrl.appendingPathComponent("cat.png"))
        let attachment = Attachment(name: "cat.png", contentType: "image/png", data: testData)

        let email = try Email(
            from: Address(testFrom),
            to: [
                Address(testTo),
            ],
            subject: "test ses with attachment",
            body: "This is an email body and attachment with SES.",
            attachments: [attachment]
        )
        
        try await testSES(email)
    }
    
    private func testSES(_ email: Email) async throws {
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
        
        try await app.mail.sender.send(email)
        try app.shutdownApplication()
    }
    
}

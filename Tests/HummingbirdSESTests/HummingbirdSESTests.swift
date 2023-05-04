import XCTest
import NIO
import Hummingbird
import HummingbirdMail
import HummingbirdSES
import SotoCore
import Logging

final class HummingbirdSESTests: XCTestCase {
    
    var from: String { ProcessInfo.processInfo.environment["MAIL_FROM"]! }
    var to: String { ProcessInfo.processInfo.environment["MAIL_TO"]! }
    
    private func send(_ email: HBMail) async throws {
        let env = ProcessInfo.processInfo.environment
        
        var logger = Logger(label: "aws-logger")
        logger.logLevel = .info
        
        let app = HBApplication()
        app.services.aws = .init(
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

        app.services.setUpSESMailer(
            using: app.aws,
            region: env["SES_REGION"]!
        )
        
        try await app.mailer.send(email)
        try app.shutdownApplication()
    }
    
    // MARK: - test cases
    
    func testSimpleText() async throws {
        let email = try HBMail(
            from: HBMailAddress(from),
            to: [
                HBMailAddress(to),
            ],
            subject: "test ses with simple text",
            body: "This is a simple text email body with SES."
        )
        try await send(email)
    }
    
    func testHMTLText() async throws {
        let email = try HBMail(
            from: HBMailAddress(from),
            to: [
                HBMailAddress(to),
            ],
            subject: "test ses with HTML text",
            body: "This is a <b>HTML text</b> email body with SES.",
            isHtml: true
        )
        try await send(email)
    }
    
    func testAttachment() async throws {
        let packageRootPath = URL(fileURLWithPath: #file)
            .pathComponents
            .prefix(while: { $0 != "Tests" })
            .joined(separator: "/")
            .dropFirst()
        let assetsUrl = URL(fileURLWithPath: String(packageRootPath))
            .appendingPathComponent("Tests")
            .appendingPathComponent("Assets")
        let testData = try Data(
            contentsOf: assetsUrl.appendingPathComponent("Hummingbird.png")
        )
        let attachment = HBMailAttachment(
            name: "Hummingbird.png",
            contentType: "image/png",
            data: testData
        )

        let email = try HBMail(
            from: HBMailAddress(from),
            to: [
                HBMailAddress(to),
            ],
            subject: "test ses with attachment",
            body: "This is an email body and attachment with SES.",
            attachments: [attachment]
        )
        try await send(email)
    }
}

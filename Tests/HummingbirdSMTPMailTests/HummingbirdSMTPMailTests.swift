import Hummingbird
import HummingbirdMail
import HummingbirdSMTPMail
import Logging
import NIO
import XCTest

final class HummingbirdMTPMailTests: XCTestCase {

    var from: String { ProcessInfo.processInfo.environment["MAIL_FROM"]! }
    var to: String { ProcessInfo.processInfo.environment["MAIL_TO"]! }

    private func send(_ email: HBMail) async throws {
        let env = ProcessInfo.processInfo.environment

        let app = HBApplication()
        app.services.setUpSMTPMailer(
            eventLoopGroup: app.eventLoopGroup,
            hostname: env["SMTP_HOST"]!,
            signInMethod: .credentials(
                username: env["SMTP_USER"]!,
                password: env["SMTP_PASS"]!
            )
        )

        try await app.mailer.send(email)
        try app.shutdownApplication()
    }

    // MARK: - test cases

    func testSimpleText() async throws {
        let email = try HBMail(
            from: HBMailAddress(from),
            to: [
                HBMailAddress(to)
            ],
            subject: "test SMTP with simple text",
            body: "This is a simple text email body with SMTP."
        )
        try await send(email)
    }

    func testHMTLText() async throws {
        let email = try HBMail(
            from: HBMailAddress(from),
            to: [
                HBMailAddress(to)
            ],
            subject: "test SMTP with HTML text",
            body: "This is a <b>HTML text</b> email body with SMTP.",
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
                HBMailAddress(to)
            ],
            subject: "test SMTP with attachment",
            body: "This is an email body and attachment with SMTP.",
            attachments: [attachment]
        )
        try await send(email)
    }
}

import Foundation
import Hummingbird
import MailKit
import NIO
import SES
import SotoSES

extension HBApplication.AWS {

    /// AWS SES  extension for Humminbird
    public struct Mail {

        var sender: SESSender

        public func send(_ email: Email) async throws -> String {
            return try await sender.send(email)
        }
    }

    public var mail: Mail {
        .init(
            sender: .init(
                client: client,
                region: Region(
                    rawValue: ProcessInfo.processInfo.environment["AWS_REGION"]!
                )
            )
        )
    }

}

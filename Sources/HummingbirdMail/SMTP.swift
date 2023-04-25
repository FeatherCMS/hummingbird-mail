import Foundation
import Hummingbird
import MailKit
import NIO
import SMTP

extension HBApplication {

    /// SMTP  extension for Humminbird
    public struct SMTP {

        private var sender: SMTPSender {
            get {
                if !app.extensions.exists(\.smtp.sender) {
                    let env = ProcessInfo.processInfo.environment
                    let smtpConfig = SMTPServerConfiguration(
                        hostname: env["SMTP_HOST"]!,
                        signInMethod: .credentials(
                            username: env["SMTP_KEY"]!,
                            password: env["SMTP_SECRET"]!
                        )
                    )
                    app.extensions.set(
                        \.smtp.sender,
                        value: .init(
                            eventLoopGroup: app.eventLoopGroup,
                            configuration: smtpConfig
                        )
                    )
                }
                return app.extensions.get(\.smtp.sender)
            }

            nonmutating set {
                app.extensions.set(\.smtp.sender, value: newValue) { sender in
                    try sender.shutdown()
                }
            }

        }

        public func send(_ email: Email, logHandler: ((String) -> Void)? = nil)
            async throws
        {
            return try await sender.send(email, logHandler: logHandler)
        }

        let app: HBApplication

    }

    public var smtp: SMTP { .init(app: self) }

}

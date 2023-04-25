import MailKit
import NIO
import SotoSES

/// Send an Email with AWS SES
public struct SESSender {

    private let ses: SES

    public init(
        client: AWSClient,
        region: Region
    ) {
        self.ses = SES(
            client: client,
            region: region
        )
    }

    /// Send an Email with SESSender
    /// - Parameter email: Email struct to send
    /// - Returns  successful sent message id
    public func send(_ email: Email) async throws -> String {
        let msg: SES.Body
        if email.isBodyHtml {
            msg = .init(html: .init(data: email.body))
        }
        else {
            msg = .init(text: .init(data: email.body))
        }
        let res = try await ses.sendEmail(
            .init(
                destination: .init(
                    bccAddresses: email.bcc.getAddressList(),
                    ccAddresses: email.cc.getAddressList(),
                    toAddresses: email.to.getAddressList()
                ),
                message: .init(
                    body: msg,
                    subject: .init(data: email.subject)
                ),
                replyToAddresses: email.replyTo.getAddressList(),
                source: email.from.address
            )
        ).get()
        return res.messageId
    }

}

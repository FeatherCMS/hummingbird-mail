import Hummingbird
import HummingbirdAWS
import HummingbirdMail
import SotoSES

public struct SESMail: HummingbirdMailService {

    let ses: SES

    init(
        client: AWSClient,
        region: Region
    ) {
        self.ses = .init(
            client: client,
            region: region,
            partition: .aws,
            endpoint: nil,
            timeout: nil,
            byteBufferAllocator: .init(),
            options: []
        )
    }
    
    public func send(_ email: Email) async throws {
        let msg: SES.Body
        if email.isHtml {
            msg = .init(html: .init(data: email.body))
        }
        else {
            msg = .init(text: .init(data: email.body))
        }
        // TODO: attachment support
        _ = try await ses.sendEmail(
            .init(
                destination: .init(
                    bccAddresses: email.bcc.map(\.email),
                    ccAddresses: email.cc.map(\.email),
                    toAddresses: email.to.map(\.email)
                ),
                message: .init(
                    body: msg,
                    subject: .init(data: email.subject)
                ),
                replyToAddresses: email.replyTo.map(\.email),
                source: email.from.email
            )
        ).get()
    }
}

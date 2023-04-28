import Hummingbird
import HummingbirdAWS
import HummingbirdMail
import SotoSESv2

extension SESMailer: HummingbirdMailService {
    
    public func send(_ email: Email) async throws {
        try await send(
            SESEmail(
                from: SESAddress(email.from.email, name: email.from.name),
                to: email.to.map {
                    SESAddress($0.email, name: $0.name)
                },
                cc: email.cc.map {
                    SESAddress($0.email, name: $0.name)
                },
                bcc: email.bcc.map {
                    SESAddress($0.email, name: $0.name)
                },
                subject: email.subject,
                body: email.body,
                isHtml: email.isHtml,
                replyTo: email.replyTo.map {
                    SESAddress($0.email, name: $0.name)
                },
                reference: email.reference,
                attachments: email.attachments.map {
                    SESAttachment(
                        name: $0.name,
                        contentType: $0.contentType,
                        data: $0.data
                    )
                }
            )
        )
    }

}

import HummingbirdMail
import NIOSMTP

extension NIOSMTP: HummingbirdMailService {

    public func send(_ email: Email) async throws {
        try await send(
            SMTPMail(
                from: SMTPAddress(email.from.email, name: email.from.name),
                to: email.to.map {
                    SMTPAddress($0.email, name: $0.name)
                },
                cc: email.cc.map {
                    SMTPAddress($0.email, name: $0.name)
                },
                bcc: email.bcc.map {
                    SMTPAddress($0.email, name: $0.name)
                },
                subject: email.subject,
                body: email.body,
                isHtml: email.isHtml,
                replyTo: email.replyTo.map {
                    SMTPAddress($0.email, name: $0.name)
                },
                reference: email.reference,
                attachments: email.attachments.map {
                    SMTPAttachment(
                        name: $0.name,
                        contentType: $0.contentType,
                        data: $0.data
                    )
                }
            )
        )
    }
}

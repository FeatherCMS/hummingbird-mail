import Hummingbird
import HummingbirdAWS
import HummingbirdMail
import SotoSESv2
import FeatherMail

struct HBSESMailer: HBMailer {

    let service: HBSESMailerService
    let logger: Logger
    let eventLoop: EventLoop
    
    func send(_ email: HBMail) async throws {
        
        let sesMail = try SESEmail(
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

        let rawMessage = SESv2.RawMessage(
            data: AWSBase64Data.base64(sesMail.rawValue)
        )
        let request = SESv2.SendEmailRequest(content: .init(raw: rawMessage))
        _ = try await service.ses.sendEmail(
            request,
            logger: logger,
            on: eventLoop
        )
    }
}

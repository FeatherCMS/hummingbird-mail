import Foundation
import NIO

public struct Email {
    public let from: EmailAddress
    public let to: [EmailAddress]?
    public let cc: [EmailAddress]?
    public let bcc: [EmailAddress]?
    public let subject: String
    public let body: String
    public let isBodyHtml: Bool
    public let replyTo: [EmailAddress]?
    public let reference: String?
    public let dateFormatted: String
    public let uuid: String

    var attachments: [Attachment] = []

    public init(
        from: EmailAddress,
        to: [EmailAddress]? = nil,
        cc: [EmailAddress]? = nil,
        bcc: [EmailAddress]? = nil,
        subject: String,
        body: String,
        isBodyHtml: Bool = false,
        replyTo: [EmailAddress]? = nil,
        reference: String? = nil
    ) throws {
        if (to?.isEmpty ?? true) == true && (cc?.isEmpty ?? true) == true
            && (bcc?.isEmpty ?? true) == true
        {
            throw EmailError.recipientNotSpecified
        }

        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.body = body
        self.isBodyHtml = isBodyHtml
        self.replyTo = replyTo
        self.reference = reference

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"

        dateFormatted = dateFormatter.string(from: date)
        uuid =
            "<\(date.timeIntervalSince1970)\(from.address.drop { $0 != "@" })>"
    }

    public mutating func addAttachment(_ attachment: Attachment) {
        attachments.append(attachment)
    }
}

public struct HBMail {
    public let from: HBMailAddress
    public let to: [HBMailAddress]
    public let cc: [HBMailAddress]
    public let bcc: [HBMailAddress]
    public let subject: String
    public let body: String
    public let isHtml: Bool
    public let replyTo: [HBMailAddress]
    public let reference: String?
    public let attachments: [HBMailAttachment]
    
    public init(
        from: HBMailAddress,
        to: [HBMailAddress] = [],
        cc: [HBMailAddress] = [],
        bcc: [HBMailAddress] = [],
        subject: String,
        body: String,
        isHtml: Bool = false,
        replyTo: [HBMailAddress] = [],
        reference: String? = nil,
        attachments: [HBMailAttachment] = []
    ) throws {
        guard !to.isEmpty || !cc.isEmpty || !bcc.isEmpty else {
            throw HBMailerError.recipientNotSpecified
        }
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.body = body
        self.isHtml = isHtml
        self.replyTo = replyTo
        self.reference = reference
        self.attachments = attachments
    }
    
}

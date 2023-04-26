public struct Email {
    public let from: Address
    public let to: [Address]
    public let cc: [Address]
    public let bcc: [Address]
    public let subject: String
    public let body: String
    public let isHtml: Bool
    public let replyTo: [Address]
    public let reference: String?
    public let attachments: [Attachment]
    
    public init(
        from: Address,
        to: [Address] = [],
        cc: [Address] = [],
        bcc: [Address] = [],
        subject: String,
        body: String,
        isHtml: Bool = false,
        replyTo: [Address] = [],
        reference: String? = nil,
        attachments: [Attachment] = []
    ) throws {
        guard !to.isEmpty || !cc.isEmpty || !bcc.isEmpty else {
            throw HummingbirdMailError.recipientNotSpecified
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

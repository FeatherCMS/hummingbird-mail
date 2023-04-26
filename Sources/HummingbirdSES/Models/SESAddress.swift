public struct SESAddress {
    public let email: String
    public let name: String?

    public init(
        _ email: String,
        name: String? = nil
    ) {
        self.email = email
        self.name = name
    }
    
    var mime: String {
        if let name {
            return "\(name) <\(email)>"
        }
        return email
    }
}

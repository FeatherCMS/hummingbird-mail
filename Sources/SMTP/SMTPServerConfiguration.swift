import NIO

/// Configuration for a SMTP provider
public struct SMTPServerConfiguration {
    public let hostname: String
    public let port: Int
    public let secure: SmtpSecureChannel
    public let connectTimeout: TimeAmount
    public let helloMethod: HelloMethod
    public let signInMethod: SignInMethod

    public init(
        hostname: String = "",
        port: Int = 587,
        signInMethod: SignInMethod,
        secure: SmtpSecureChannel = .startTls,
        connectTimeout: TimeAmount = TimeAmount.seconds(10),
        helloMethod: HelloMethod = .helo
    ) {
        self.hostname = hostname
        self.port = port
        self.secure = secure
        self.connectTimeout = connectTimeout
        self.helloMethod = helloMethod
        self.signInMethod = signInMethod
    }
}

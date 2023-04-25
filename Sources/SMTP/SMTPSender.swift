import MailKit
import NIO

/// Send an Email with an SMTP provider
public struct SMTPSender {

    private let eventLoopGroup: EventLoopGroup
    private let configuration: SMTPServerConfiguration

    public init(
        eventLoopGroup: EventLoopGroup,
        configuration: SMTPServerConfiguration
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.configuration = configuration
    }

    /// Send an Email with SMTPSender
    /// - Parameter email: Email struct to send
    /// - Parameter logHandler: optional closure, It allows for custom logging of the function's output
    public func send(_ email: Email, logHandler: ((String) -> Void)? = nil)
        async throws
    {
        let result = try await sendWithPromise(
            email: email,
            logHandler: logHandler
        )
        .get()
        switch result {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }
    }

    /// shutdown EventLoopGroup
    public func shutdown() throws {
        try eventLoopGroup.syncShutdownGracefully()
    }

    private func sendWithPromise(email: Email, logHandler: ((String) -> Void)?)
        throws
        -> EventLoopFuture<Result<Bool, Error>>
    {
        let eventLoop = eventLoopGroup.next()
        let promise: EventLoopPromise<Void> = eventLoop.makePromise()
        let bootstrap = ClientBootstrap(group: eventLoop)
            .connectTimeout(configuration.connectTimeout)
            .channelOption(
                ChannelOptions.socket(
                    SocketOptionLevel(SOL_SOCKET),
                    SO_REUSEADDR
                ),
                value: 1
            )
            .channelInitializer { channel in
                let secureChannelFuture = configuration.secure.configureChannel(
                    on: channel,
                    hostname: configuration.hostname
                )
                return secureChannelFuture.flatMap {
                    let defaultHandlers: [ChannelHandler] = [
                        DuplexMessagesHandler(handler: logHandler),
                        ByteToMessageHandler(InboundLineBasedFrameDecoder()),
                        InboundSmtpResponseDecoder(),
                        MessageToByteHandler(OutboundSmtpRequestEncoder()),
                        StartTlsHandler(
                            configuration: configuration,
                            promise: promise
                        ),
                        InboundSendEmailHandler(
                            configuration: configuration,
                            emailToSend: email,
                            promise: promise
                        ),
                    ]
                    return channel.pipeline.addHandlers(
                        defaultHandlers,
                        position: .last
                    )
                }
            }

        let connection = bootstrap.connect(
            host: configuration.hostname,
            port: configuration.port
        )
        connection.cascadeFailure(to: promise)

        return promise.futureResult.map { () -> Result<Bool, Error> in
            connection.whenSuccess { $0.close(promise: nil) }
            return Result.success(true)
        }.flatMapError { error -> EventLoopFuture<Result<Bool, Error>> in
            return eventLoop.makeSucceededFuture(Result.failure(error))
        }
    }

}

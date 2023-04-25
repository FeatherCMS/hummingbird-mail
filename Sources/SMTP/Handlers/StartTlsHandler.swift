import NIO
import NIOSSL

final class StartTlsHandler: ChannelDuplexHandler,
    RemovableChannelHandler
{
    typealias InboundIn = SmtpResponse
    typealias InboundOut = SmtpResponse
    typealias OutboundIn = SmtpRequest
    typealias OutboundOut = SmtpRequest

    private let serverConfiguration: SMTPServerConfiguration
    private let allDonePromise: EventLoopPromise<Void>
    private var waitingForStartTlsResponse = false

    init(
        configuration: SMTPServerConfiguration,
        promise: EventLoopPromise<Void>
    ) {
        serverConfiguration = configuration
        allDonePromise = promise
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        if startTlsDisabled() {
            return context.fireChannelRead(data)
        }

        if waitingForStartTlsResponse {
            waitingForStartTlsResponse = false

            let result = unwrapInboundIn(data)
            switch result {
            case .error(let message):
                if serverConfiguration.secure == .startTls {
                    return allDonePromise.fail(SmtpError(message))
                }
                let startTlsResult = wrapInboundOut(
                    .ok(200, "STARTTLS is not supported")
                )
                return context.fireChannelRead(startTlsResult)
            case .ok:
                initializeTlsHandler(context: context, data: data)
            }
        }
        else {
            context.fireChannelRead(data)
        }
    }

    func write(
        context: ChannelHandlerContext,
        data: NIOAny,
        promise: EventLoopPromise<Void>?
    ) {
        if startTlsDisabled() {
            return context.write(data, promise: promise)
        }

        let command = unwrapOutboundIn(data)
        switch command {
        case .startTls:
            waitingForStartTlsResponse = true
        default:
            break
        }

        context.write(data, promise: promise)
    }

    private func initializeTlsHandler(
        context: ChannelHandlerContext,
        data: NIOAny
    ) {
        do {
            let sslContext = try NIOSSLContext(
                configuration: .makeClientConfiguration()
            )
            let sslHandler = try NIOSSLClientHandler(
                context: sslContext,
                serverHostname: serverConfiguration.hostname
            )
            _ = context.channel.pipeline.addHandler(
                sslHandler,
                name: "NIOSSLClientHandler",
                position: .first
            )

            context.fireChannelRead(data)
            _ = context.channel.pipeline.removeHandler(self)
        }
        catch let error {
            allDonePromise.fail(error)
        }
    }

    private func startTlsDisabled() -> Bool {
        serverConfiguration.secure != .startTls
            && serverConfiguration.secure != .startTlsWhenAvailable
    }
}

import NIO

final class DuplexMessagesHandler: ChannelDuplexHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let handler: ((String) -> Void)?

    init(handler: ((String) -> Void)? = nil) {
        self.handler = handler
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        if let handler = handler {
            let buffer = unwrapInboundIn(data)
            handler(
                "==> \(String(decoding: buffer.readableBytesView, as: UTF8.self))"
            )
        }
        context.fireChannelRead(data)
    }

    func write(
        context: ChannelHandlerContext,
        data: NIOAny,
        promise: EventLoopPromise<Void>?
    ) {
        if let handler = handler {
            let buffer = unwrapOutboundIn(data)
            handler(
                "<== \(String(decoding: buffer.readableBytesView, as: UTF8.self))"
            )
        }
        context.write(data, promise: promise)
    }

}

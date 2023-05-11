import Logging
import NIOCore

public protocol HBMailerService {

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBMailer
}

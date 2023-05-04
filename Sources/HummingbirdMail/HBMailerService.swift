import NIOCore
import Logging

public protocol HBMailerService {
    
    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBMailer
}

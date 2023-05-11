import NIOCore
import Logging
import FeatherMail

public protocol HBMailerService {
    
    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBMailer
}

import Hummingbird
import HummingbirdServices

extension HBApplication.Services {

    public var mailer: HBMailerService {
        get {
            get(\.services.mailer, "Mailer service is not configured")
        }
        nonmutating set {
            set(\.services.mailer, newValue)
        }
    }
}

extension HBApplication {

    public var mailer: HBMailer {
        services.mailer.make(
            logger: logger,
            eventLoop: eventLoopGroup.next()
        )
    }
}

extension HBRequest {

    public var mailer: HBMailer {
        application.services.mailer.make(
            logger: logger,
            eventLoop: eventLoop
        )
    }
}

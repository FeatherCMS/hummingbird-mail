import Hummingbird
import HummingbirdServices

public extension HBApplication.Services {

    var mailer: HBMailerService {
        get {
            get(\.services.mailer, "Mailer service is not configured")
        }
        nonmutating set {
            set(\.services.mailer, newValue)
        }
    }
}

public extension HBApplication {

    var mailer: HBMailer {
        services.mailer.make(
            logger: logger,
            eventLoop: eventLoopGroup.next()
        )
    }
}

public extension HBRequest {

    var mailer: HBMailer {
        application.services.mailer.make(
            logger: logger,
            eventLoop: eventLoop
        )
    }
}

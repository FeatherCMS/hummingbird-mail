import HummingbirdMail
import SotoCore
import SotoSESv2

struct HBSESMailerService: HBMailerService {

    let ses: SESv2

    init(
        aws: AWSClient,
        region: Region
    ) {
        self.ses = .init(
            client: aws,
            region: region,
            partition: .aws,
            endpoint: nil,
            timeout: nil,
            byteBufferAllocator: .init(),
            options: []
        )
    }

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBMailer {
        HBSESMailer(
            ses: ses,
            logger: logger,
            eventLoop: eventLoop
        )
    }
}


import NIO
import Logging
import HummingbirdMail
import SotoSES

public extension HummingbirdMailService where Self == SESMailer {

    static func ses(
        client: AWSClient,
        region: Region
    ) -> HummingbirdMailService {
        SESMailer(
            client: client,
            region: region
        )
    }
}

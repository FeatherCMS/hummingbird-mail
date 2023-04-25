import NIO
import Logging
import HummingbirdMail
import SotoSES

public extension HummingbirdMailService where Self == SESMail {

    static func ses(
        client: AWSClient,
        region: Region
    ) -> HummingbirdMailService {
        SESMail(
            client: client,
            region: region
        )
    }
}

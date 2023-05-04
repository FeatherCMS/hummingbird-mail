import Hummingbird
import HummingbirdServices
import HummingbirdMail
import SotoSESv2

public extension HBApplication.Services {

    func setUpSESMailer(
        using aws: AWSClient,
        region: String
    ) {
        mailer = HBSESMailerService(
            aws: aws,
            region: .init(rawValue: region)
        )
    }
}

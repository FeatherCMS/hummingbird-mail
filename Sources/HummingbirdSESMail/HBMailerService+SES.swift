import Hummingbird
import HummingbirdMail
import HummingbirdServices
import SotoCore

extension HBApplication.Services {

    public func setUpSESMailer(
        using aws: AWSClient,
        region: String
    ) {
        mailer = HBSESMailerService(
            aws: aws,
            region: .init(rawValue: region)
        )
    }
}

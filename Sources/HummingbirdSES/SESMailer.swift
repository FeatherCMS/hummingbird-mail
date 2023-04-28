import Hummingbird
import HummingbirdAWS
import HummingbirdMail
import SotoCore
import SotoSESv2

public struct SESMailer {

    let ses: SESv2

    init(
        client: AWSClient,
        region: Region
    ) {
        self.ses = .init(
            client: client,
            region: region,
            partition: .aws,
            endpoint: nil,
            timeout: nil,
            byteBufferAllocator: .init(),
            options: []
        )
    }

    func send(_ email: SESEmail) async throws {
        let rawMessage = SESv2.RawMessage(data: AWSBase64Data.base64(email.getSESRaw()))
        let request = SESv2.SendEmailRequest(content: .init(raw: rawMessage))
        _ = try await ses.sendEmail(request)
    }
}

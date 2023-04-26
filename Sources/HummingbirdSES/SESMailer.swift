import Hummingbird
import HummingbirdAWS
import HummingbirdMail
import SotoSES

public struct SESMailer {

    let ses: SES

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
    
    public func send(_ email: SESEmail) async throws {
        let rawMessage = SES.RawMessage(data: AWSBase64Data.base64(email.getSESRaw()))
        let rawRequest = SES.SendRawEmailRequest(rawMessage: rawMessage)
        _ = try await ses.sendRawEmail(rawRequest).get()
    }

}

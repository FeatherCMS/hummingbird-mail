import Foundation
import NIO

extension Email {

    ///wrire Email content into a ByteBuffer
    public func write(to out: inout ByteBuffer) {

        out.writeString("From: \(formatMIME(emailAddress: from))\r\n")

        if let to = to {
            let toAddresses = to.map { formatMIME(emailAddress: $0) }
                .joined(separator: ", ")
            out.writeString("To: \(toAddresses)\r\n")
        }

        if let cc = cc {
            let ccAddresses = cc.map { formatMIME(emailAddress: $0) }
                .joined(separator: ", ")
            out.writeString("Cc: \(ccAddresses)\r\n")
        }

        if let replyTo = replyTo {
            let replyToAddresses = replyTo.map {
                formatMIME(emailAddress: $0)
            }.joined(separator: ", ")
            out.writeString("Reply-to: \(replyToAddresses)\r\n")
        }

        out.writeString("Subject: \(subject)\r\n")
        out.writeString("Date: \(dateFormatted)\r\n")
        out.writeString("Message-ID: \(uuid)\r\n")

        if let reference = reference {
            out.writeString("In-Reply-To: \(reference)\r\n")
            out.writeString("References: \(reference)\r\n")
        }

        let boundary = boundary()
        if attachments.count > 0 {
            out.writeString(
                "Content-type: multipart/mixed; boundary=\"\(boundary)\"\r\n"
            )
            out.writeString("Mime-Version: 1.0\r\n\r\n")
        }
        else if isBodyHtml {
            out.writeString("Content-Type: text/html; charset=\"UTF-8\"\r\n")
            out.writeString("Mime-Version: 1.0\r\n\r\n")
        }
        else {
            out.writeString("Content-Type: text/plain; charset=\"UTF-8\"\r\n")
            out.writeString("Mime-Version: 1.0\r\n\r\n")
        }

        if attachments.count > 0 {

            if isBodyHtml {
                out.writeString("--\(boundary)\r\n")
                out.writeString(
                    "Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n"
                )
                out.writeString("\(body)\r\n")
                out.writeString("--\(boundary)\r\n")
            }
            else {
                out.writeString("--\(boundary)\r\n")
                out.writeString(
                    "Content-Type: text/plain; charset=\"UTF-8\"\r\n\r\n"
                )
                out.writeString("\(body)\r\n\r\n")
                out.writeString("--\(boundary)\r\n")
            }

            for attachment in attachments {
                out.writeString("Content-type: \(attachment.contentType)\r\n")
                out.writeString("Content-Transfer-Encoding: base64\r\n")
                out.writeString(
                    "Content-Disposition: attachment; filename=\"\(attachment.name)\"\r\n\r\n"
                )
                out.writeString("\(attachment.data.base64EncodedString())\r\n")
                out.writeString("--\(boundary)\r\n")
            }

        }
        else {
            out.writeString(body)
        }

        out.writeString("\r\n.")
    }

    private func boundary() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
            .lowercased()
    }

    private func formatMIME(emailAddress: EmailAddress) -> String {
        if let name = emailAddress.name {
            return "\(name) <\(emailAddress.address)>"
        }
        else {
            return emailAddress.address
        }
    }
}

extension [EmailAddress]? {
    public func getAddressList() -> [String]? {
        if self != nil {
            var result = [String]()
            for item in self! {
                result.append(item.address)
            }
            return result
        }
        return nil
    }
}

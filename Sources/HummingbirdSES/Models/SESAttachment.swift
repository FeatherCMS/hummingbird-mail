import Foundation

struct SESAttachment {
    let name: String
    let contentType: String
    let data: Data

    init(
        name: String,
        contentType: String,
        data: Data
    ) {
        self.name = name
        self.contentType = contentType
        self.data = data
    }
}

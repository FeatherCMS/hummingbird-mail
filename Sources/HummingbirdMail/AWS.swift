import Foundation
import Hummingbird
import SotoCore

extension HBApplication {

    /// AWS  extension for Humminbird
    public struct AWS {

        public var client: AWSClient {
            get {
                if !app.extensions.exists(\.aws.client) {

                    let logger = Logger(label: "aws-logger")
                    let env = ProcessInfo.processInfo.environment

                    app.extensions.set(
                        \.aws.client,
                        value: .init(
                            credentialProvider: .static(
                                accessKeyId: env["AWS_ACCESS_KEY"]!,
                                secretAccessKey: env["AWS_ACCESS_SECRET"]!
                            ),
                            httpClientProvider: .createNewWithEventLoopGroup(
                                app.eventLoopGroup
                            ),
                            logger: logger
                        )
                    )
                }
                return app.extensions.get(\.aws.client)
            }
            nonmutating set {
                app.extensions.set(\.aws.client, value: newValue) { client in
                    try client.syncShutdown()
                }
            }
        }

        let app: HBApplication
    }

    public var aws: AWS { .init(app: self) }
}

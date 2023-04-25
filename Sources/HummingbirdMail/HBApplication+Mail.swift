import Hummingbird

extension HBApplication {

    /// AWS  extension
    public struct Mail {

        public var sender: HummingbirdMailService {
            get {
                if !app.extensions.exists(\.mail.sender) {
                    fatalError("Mail sender is not configured.")
                }
                return app.extensions.get(\.mail.sender)
            }
            nonmutating set {
                app.extensions.set(\.mail.sender, value: newValue) { sender in
                    // NOTE: shutdown?
                }
            }
        }

        let app: HBApplication
    }

    /// mail extension
    public var mail: Mail { .init(app: self) }
}

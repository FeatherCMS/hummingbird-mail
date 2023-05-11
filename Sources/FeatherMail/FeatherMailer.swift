public protocol HBMailer {
    func send(_ email: HBMail) async throws
}

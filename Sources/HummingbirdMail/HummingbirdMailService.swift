public protocol HummingbirdMailService {
    func send(_ email: Email) async throws
}

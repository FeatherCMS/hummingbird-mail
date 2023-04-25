import MailKit
import NIO
import NIOSSL

final class InboundSendEmailHandler: ChannelInboundHandler {
    typealias InboundIn = SmtpResponse
    typealias OutboundOut = SmtpRequest

    enum Expect {
        case initialMessageFromServer
        case okAfterHello
        case okAfterStartTls
        case okAfterStartTlsHello
        case okAfterAuthBegin
        case okAfterUsername
        case okAfterPassword
        case okAfterMailFrom
        case okAfterRecipient
        case okAfterDataCommand
        case okAfterMailData
        case okAfterQuit
        case nothing
        case error
    }

    private var currentlyWaitingFor = Expect.initialMessageFromServer
    private let email: Email
    private let serverConfiguration: SMTPServerConfiguration
    private let allDonePromise: EventLoopPromise<Void>
    private var recipients: [EmailAddress] = []

    init(
        configuration: SMTPServerConfiguration,
        emailToSend: Email,
        promise: EventLoopPromise<Void>
    ) {
        email = emailToSend
        allDonePromise = promise
        serverConfiguration = configuration

        if let to = email.to {
            recipients += to
        }
        if let cc = email.cc {
            recipients += cc
        }
        if let bcc = email.bcc {
            recipients += bcc
        }
    }

    func send(context: ChannelHandlerContext, command: SmtpRequest) {
        context.writeAndFlush(wrapOutboundOut(command)).cascadeFailure(
            to: allDonePromise
        )
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let result = unwrapInboundIn(data)
        switch result {
        case .error(let message):
            allDonePromise.fail(SmtpError(message))
            return
        case .ok:
            ()
        }

        switch currentlyWaitingFor {
        case .initialMessageFromServer:
            send(
                context: context,
                command: .sayHello(
                    serverName: serverConfiguration.hostname,
                    helloMethod: serverConfiguration.helloMethod
                )
            )
            currentlyWaitingFor = .okAfterHello
        case .okAfterHello:

            if shouldInitializeTls() {
                send(context: context, command: .startTls)
                currentlyWaitingFor = .okAfterStartTls
            }
            else {
                switch serverConfiguration.signInMethod {
                case .credentials(_, _):
                    send(context: context, command: .beginAuthentication)
                    currentlyWaitingFor = .okAfterAuthBegin
                case .anonymous:
                    send(
                        context: context,
                        command: .mailFrom(email.from.address)
                    )
                    currentlyWaitingFor = .okAfterMailFrom
                }
            }

        case .okAfterStartTls:
            send(
                context: context,
                command: .sayHelloAfterTls(
                    serverName: serverConfiguration.hostname,
                    helloMethod: serverConfiguration.helloMethod
                )
            )
            currentlyWaitingFor = .okAfterStartTlsHello
        case .okAfterStartTlsHello:
            send(context: context, command: .beginAuthentication)
            currentlyWaitingFor = .okAfterAuthBegin
        case .okAfterAuthBegin:

            switch serverConfiguration.signInMethod {
            case .credentials(let username, _):
                send(context: context, command: .authUser(username))
                currentlyWaitingFor = .okAfterUsername
            case .anonymous:
                allDonePromise.fail(
                    SmtpError(
                        "After auth begin executed for anonymous sign in method"
                    )
                )
                break
            }

        case .okAfterUsername:
            switch serverConfiguration.signInMethod {
            case .credentials(_, let password):
                send(context: context, command: .authPassword(password))
                currentlyWaitingFor = .okAfterPassword
            case .anonymous:
                allDonePromise.fail(
                    SmtpError(
                        "After user name executed for anonymous sign in method"
                    )
                )
                break
            }

        case .okAfterPassword:
            send(
                context: context,
                command: .mailFrom(email.from.address)
            )
            currentlyWaitingFor = .okAfterMailFrom
        case .okAfterMailFrom:
            if let recipient = recipients.popLast() {
                send(
                    context: context,
                    command: .recipient(recipient.address)
                )
            }
            else {
                fallthrough
            }
        case .okAfterRecipient:
            send(context: context, command: .data)
            currentlyWaitingFor = .okAfterDataCommand
        case .okAfterDataCommand:
            send(context: context, command: .transferData(email))
            currentlyWaitingFor = .okAfterMailData
        case .okAfterMailData:
            send(context: context, command: .quit)
            currentlyWaitingFor = .okAfterQuit
        case .okAfterQuit:
            allDonePromise.succeed(())
            currentlyWaitingFor = .nothing
        case .nothing:
            ()
        case .error:
            allDonePromise.fail(SmtpError("Communication error state"))
        }
    }

    private func shouldInitializeTls() -> Bool {
        serverConfiguration.secure == .startTls
            || serverConfiguration.secure == .startTlsWhenAvailable
    }
}

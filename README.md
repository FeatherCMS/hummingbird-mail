##Feather Mail Component

A [Hummingbird](https://github.com/hummingbird-project/hummingbird) mail component, which handles email sending wih [AWS SES](https://aws.amazon.com/ses/) or with other [SMTP](https://hu.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) providers.


###AWS SES

Simple usage

```
let email = try Email(...)
let logger = Logger(label: "aws-logger")
let eventLoopGroup = MultiThreadedEventLoopGroup(
    numberOfThreads: System.coreCount
)
let client = AWSClient.init(
    credentialProvider: .static(
        accessKeyId: "#Your SES access key#",
        secretAccessKey: "#Your SES secret access key#"
    ),
    httpClientProvider: .createNewWithEventLoopGroup(
        eventLoopGroup
    ),
    logger: logger
)
let sender = SESSender(
    client: client,
    region: .uswest1
)
try await sender.send(email)
try client.syncShutdown()
```
or can use it as a Hummingbird extension

```
let email = try Email(...)
try await self.aws.mail.send(email)

```

###SMTP

Simple usage

```
let configuration = SMTPServerConfiguration(
    hostname: "#Your SMTP host#",
    signInMethod: .credentials(
        username: "#Your SMTP username#",
        password: "#Your SMTP password#"
    )
)

let email = try Email(...)
let eventLoopGroup = MultiThreadedEventLoopGroup(
    numberOfThreads: System.coreCount
)
let sender = SMTPSender(
    eventLoopGroup: eventLoopGroup,
    configuration: configuration
)
try await sender.send(email) { message in print(message) }
try sender.shutdown()
```

or can use it as a Hummingbird extension

```
let email = try Email(...)
try await self.smtp.send(email)
```

SMTP sending greatly inspired by [Mikroservices/Smtp](https://github.com/Mikroservices/Smtp)

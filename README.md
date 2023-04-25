# Hummingbird Mail Component

A [Hummingbird](https://github.com/hummingbird-project/hummingbird) mail component, which can send emails using via [AWS SES](https://aws.amazon.com/ses/) or [SMTP](https://hu.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) providers.

## Getting started 

Adding the dependency

Add the following entry in your Package.swift to start using HummingbirdAWS:

```swift
.package(url: "https://github.com/feathercms/hummingbird-mail", from: "1.0.0"),
```

and HummingbirdMail dependency to your target:

```swift
.product(name: "HummingbirdMail", package: "hummingbird-mail"),
```

Mail provider services

```swift
.product(name: "HummingbirdSMTP", package: "hummingbird-mail"),
.product(name: "HummingbirdSES", package: "hummingbird-mail"),
```    

## HummingbirdSES

Simple usage

```swift
import Hummingbird
import HummingbirdMail
import HummingbirdSES

let env = ProcessInfo.processInfo.environment
let logger = Logger(label: "aws-logger")

let app = HBApplication()
app.aws.client = .init(
    credentialProvider: .static(
        accessKeyId: env["SES_ID"]!,
        secretAccessKey: env["SES_SECRET"]!
    ),
    httpClientProvider: .createNewWithEventLoopGroup(
        app.eventLoopGroup
    ),
    logger: logger
)

app.mail.sender = .ses(
    client: app.aws.client,
    region: .init(awsRegionName: env["SES_REGION"]!)!
)

let email = try Email(
    from: Address(env["MAIL_FROM"]!),
    to: [
        Address(env["MAIL_TO"]!),
    ],
    subject: "test smtp",
    body: "This is a <b>SMTP</b> test email body.",
    isHtml: true
)

try await app.mail.sender.send(email)
try app.shutdownApplication()
```

## SMTP

Simple usage

```swift
import Hummingbird
import HummingbirdMail
import HummingbirdSMTP

let env = ProcessInfo.processInfo.environment

let app = HBApplication()
app.mail.sender = .smtp(
    eventLoopGroup: app.eventLoopGroup,
    hostname: env["SMTP_HOST"]!,
    signInMethod: .credentials(
        username: env["SMTP_USER"]!,
        password: env["SMTP_PASS"]!
    )
)

let email = try Email(
    from: Address(env["MAIL_FROM"]!),
    to: [
        Address(env["MAIL_TO"]!),
    ],
    subject: "test smtp",
    body: "This is a <b>SMTP</b> test email body.",
    isHtml: true
)

try await app.mail.sender.send(email)
try app.shutdownApplication()
```

## Credits 

The NIOSMTP library is heavily inspired by [Mikroservices/Smtp](https://github.com/Mikroservices/Smtp).
